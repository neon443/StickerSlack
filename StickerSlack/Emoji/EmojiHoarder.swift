//
//  EmojiHoarder.swift
//  StickerSlack
//
//  Created by neon443 on 15/10/2025.
//

import Foundation
import SwiftUI
import Combine
import UniformTypeIdentifiers
import Haptics

class EmojiHoarder: ObservableObject {
	static let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.neon443.StickerSlack")!.appendingPathComponent("Library", conformingTo: .directory)
	nonisolated static let localEmojiDB: URL = EmojiHoarder.container.appendingPathComponent("_localEmojiDB.json", conformingTo: .fileURL)
	nonisolated static let localTrie: URL = EmojiHoarder.container.appendingPathComponent("_localTrie.json", conformingTo: .fileURL)
	nonisolated static let localTrieDict: URL = EmojiHoarder.container.appendingPathComponent("_localTrieDict.json", conformingTo: .fileURL)
	private let endpoint: URL = URL(string: "https://cachet.dunkirk.sh/emojis")!
	private let encoder = JSONEncoder()
	private let decoder = JSONDecoder()
	
	@Published var emojis: [Emoji] = []
	
	@Published var trie: Trie = Trie()
	@Published var downloadedEmojis: Set<String> = []
	@Published var downloadedEmojisArr: [String] = []
	@Published var searchTerm: String = ""
	
	@Published var letterStats: [EmojiHoarder.LetterStat] = []
	@Published var letterStatsSorting: EmojiHoarder.LetterStatSorting = .init(by: .letter, ascending: true)
	
	@Published var showWelcome: Bool = false
	
	init(localOnly: Bool = false, skipIndex: Bool = false) {
		self.showWelcome = !UserDefaults.standard.bool(forKey: "showWelcome")
		
		let localDB = loadLocalDB()
		withAnimation { self.emojis = localDB }
		loadTrie()
		if !skipIndex { buildTrie() }
		
		guard !localOnly else { return }
		Task {
			print("start loading remote db")
			await self.loadRemoteDB()
			print("end")
			if !skipIndex {
				await self.buildTrie()
			}
		}
	}
	
	func storeStickers(_ toStore: [UUID]) {
		for stickerId in toStore {
			print(stickerId)
		}
	}
	
	@MainActor
	func deleteAllStickers() {
		for i in emojis.indices {
			guard downloadedEmojis.contains(emojis[i].name) else { continue }
			delete(emoji: emojis[i])
		}
	}
	
	func storeDB() {
		try! encoder.encode(emojis).write(to: EmojiHoarder.localEmojiDB)
	}
	
	func storeDB(data: Data) {
		try! data.write(to: EmojiHoarder.localEmojiDB)
	}
	
	func resetTrie() {
		trie.root = TrieNode()
		trie.dict = [:]
		downloadedEmojis = []
	}
	
	//cl i disabled ts cos its quicker to rebuild it then to load ts
	func saveTrie() {
//		return
//		guard let data = try? encoder.encode(trie.root) else {
//			fatalError("failed to encode trie")
//		}
//		try! data.write(to: EmojiHoarder.localTrie)
		
		guard let dataDict = try? encoder.encode(trie.dict) else {
			fatalError("failed to encode trie dict")
		}
		try! dataDict.write(to: EmojiHoarder.localTrieDict)
	}
	
	func loadTrie() {
//		return
//		guard FileManager.default.fileExists(atPath: EmojiHoarder.localTrie.path) else { return }
//		guard let data = try? Data(contentsOf: EmojiHoarder.localTrie) else { return }
//		guard let decoded = try? decoder.decode(TrieNode.self, from: data) else {
//			fatalError("failed to decode trie")
//		}
//		self.trie.root = decoded
		
		guard FileManager.default.fileExists(atPath: EmojiHoarder.localTrieDict.path) else { return }
		guard let dataDict = try? Data(contentsOf: EmojiHoarder.localTrieDict) else { return }
		guard let decodedDict = try? decoder.decode([String:Emoji].self, from: dataDict) else {
			fatalError("failed to decode dict")
		}
		self.trie.dict = decodedDict
	}
	
	func buildTrie() {
		let start = Date().timeIntervalSince1970
		for emoji in emojis {
			trie.insert(word: emoji.name)
		}
		buildTrieDict()
		saveTrie()
		generateLetterStats()
		print("done building trie in", Date().timeIntervalSince1970-start)
	}
	
	func buildTrieDict() {
		for emoji in emojis {
			trie.dict[emoji.name] = emoji
		}
		buildDownloadedEmojis()
	}
	
	func buildDownloadedEmojis() {
		downloadedEmojis = []
		downloadedEmojisArr = []
		downloadedEmojisArr = (try? JSONDecoder().decode([String].self, from: UserDefaults.standard.data(forKey: "downloadedEmojisArr") ?? Data())) ?? []
		downloadedEmojis = (try? JSONDecoder().decode(Set<String>.self, from: UserDefaults.standard.data(forKey: "downloadedEmojis") ?? Data())) ?? []
		
		if downloadedEmojis.isEmpty || downloadedEmojisArr.isEmpty {
			for emoji in emojis {
				guard emoji.isLocal else { continue }
				downloadedEmojis.insert(emoji.name)
				downloadedEmojisArr.append(emoji.name)
			}
		}
		
		UserDefaults.standard.set(try! JSONEncoder().encode(downloadedEmojis), forKey: "downloadedEmojis")
		UserDefaults.standard.set(try! JSONEncoder().encode(downloadedEmojisArr), forKey: "downloadedEmojisArr")
	}
	
	nonisolated
	func loadLocalDB() -> [Emoji] {
		if let localEmojiDB = try? Data(contentsOf: EmojiHoarder.localEmojiDB) {
			let decoded = try! decoder.decode([Emoji].self, from: localEmojiDB)
			return decoded
		}
		return []
	}
	
	func loadRemoteDB() async {
		async let fetched = self.fetchRemoteDB()
		if let fetched = await fetched {
			withAnimation { self.emojis = fetched }
		}
	}
	
	nonisolated
	func fetchRemoteDB() async -> [Emoji]? {
		do {
			async let (data, _) = try URLSession.shared.data(from: endpoint)
			decoder.dateDecodingStrategy = .iso8601
			let decoded: [SlackResponse] = try decoder.decode([SlackResponse].self, from: await data)
			try await storeDB(data: await data)
			return await SlackResponse.toEmojis(from: decoded)
		} catch {
			print(error.localizedDescription)
			return nil
		}
	}
	
	func refreshDB() async {
		guard let fetched = await self.fetchRemoteDB() else {
			let local = loadLocalDB()
			await MainActor.run {
				emojis = local
				buildTrie()
			}
			return
		}
		await MainActor.run {
			withAnimation { self.emojis = fetched }
			buildTrie()
		}
	}
	
	func download(emoji: Emoji) {
		Task.detached {
			try? await emoji.downloadImage()
			await MainActor.run {
				self.downloadedEmojis.insert(emoji.name)
				self.downloadedEmojisArr.append(emoji.name)
				self.trie.dict[emoji.name]?.refresh()
				Haptic.success.trigger()
			}
		}
	}
	
	@MainActor
	func delete(emoji: Emoji) {
		emoji.deleteImage()
		downloadedEmojis.remove(emoji.name)
		downloadedEmojisArr.removeAll(where: { $0 == emoji.name })
		self.trie.dict[emoji.name]?.refresh()
		Haptic.heavy.trigger()
	}
	
	func setShowWelcome(to newValue: Bool) {
		UserDefaults.standard.set(!newValue, forKey: "showWelcome")
		self.showWelcome = newValue
	}
	
	func generateLetterStats() {
		var result: [EmojiHoarder.LetterStat] = []
		for child in trie.root.children {
			let count = trie.collectWords(startingWith: child.key, from: child.value).count
			let stat = LetterStat(char: child.key, count: count)
			result.append(stat)
		}
		self.letterStats = result
		sortLetterStats(by: self.letterStatsSorting)
	}
	
	func sortLetterStats(by: EmojiHoarder.LetterStatSorting) {
		self.letterStatsSorting = by
		let sortByLetter = letterStatsSorting.by == .letter
		switch by.ascending {
		case true:
			letterStats.sort {
				if sortByLetter {
					$0.char > $1.char
				} else {
					$0.count > $1.count
				}
			}
		case false:
			letterStats.sort {
				if sortByLetter {
					$0.char > $1.char
				} else {
					$0.count < $1.count
				}
			}
		}
	}
	
	struct LetterStat: Hashable {
		var char: String
		var count: Int
	}
	enum SortLetterStatsBy: String, CaseIterable {
		case letter = "Letter"
		case count = "Count"
	}
	struct LetterStatSorting: Hashable, Equatable {
		var by: EmojiHoarder.SortLetterStatsBy = .count
		var ascending: Bool = true
	}
	
//	func filterEmojis(byCategory category: FilterCategory, searchTerm: String) {
//		guard category != .none else {
//			filterEmojis(by: searchTerm)
//			return
//		}
//		self.filterEmojis(by: searchTerm)
//		DispatchQueue.main.async {
//			switch category {
//			case .none:
//				fallthrough
//			case .downloaded:
//				withAnimation(.interactiveSpring) { self.filteredEmojis = self.filteredEmojis.filter { $0.isLocal } }
//			case .notDownloaded:
//				withAnimation(.interactiveSpring) { self.filteredEmojis = self.filteredEmojis.filter { !$0.isLocal } }
//			}
//		}
//	}
}
