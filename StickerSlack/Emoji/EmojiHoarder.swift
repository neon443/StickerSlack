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

class EmojiHoarder: Hoarder, ObservableObject {
	static let container: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.neon443.StickerSlack")!.appendingPathComponent("Library", conformingTo: .directory)
	nonisolated static let localEmojiDB: URL = EmojiHoarder.container.appendingPathComponent("_____localEmojiDB.json", conformingTo: .fileURL)
	nonisolated static let localTrie: URL = EmojiHoarder.container.appendingPathComponent("_____localTrie.json", conformingTo: .fileURL)
	nonisolated static let localTrieDict: URL = EmojiHoarder.container.appendingPathComponent("_____localTrieDict.json", conformingTo: .fileURL)
	let endpoint: URL = URL(string: "https://cachet.dunkirk.sh/emojis")!
	
	@Published var emojis: [Emoji] = []
	@Published var emojiPacks: [EmojiPack] = []
	
	@Published var trie: Trie = Trie()
	@Published var downloadedStickers: Set<String> = []
	
	@Published var letterStats: [EmojiHoarder.LetterStat] = []
	@Published var letterStatsSorting: EmojiHoarder.LetterStatSorting = .init(by: .letter, ascending: true)
	
	@Published var showWelcome: Bool = false
	
	init(localOnly: Bool = false, skipIndex: Bool = false) {
		self.showWelcome = !UserDefaults.standard.bool(forKey: "showWelcome")
		
		let localDB = loadLocalDB()
		withAnimation(.snappy) { self.emojis = localDB }
		loadTrie()
		if !skipIndex { buildTrie() }
		
		guard !localOnly else { return }
		Task.detached {
			print("start loading remote db")
			await self.loadRemoteDB()
			print("end")
			if !skipIndex {
				await self.buildTrie()
			}
		}
	}
	
	@MainActor
	func downloadAllStickers() async {
		let start: Date = .now
		
		
		let cores = ProcessInfo.processInfo.processorCount-1
		var ranges: [Range<Int>] = []
		for i in 0..<cores {
			let onething = emojis.count/cores
			ranges.append(onething*i..<onething + (onething*i))
			if i == (0..<cores).last {
				let last = ranges.last!
				ranges.removeLast()
				ranges.append(onething*i..<(onething + (onething*i)+emojis.count-last.upperBound))
			}
		}
		
		await withTaskGroup { group in
			for range in ranges {
				group.addTask {
					for i in range {
						guard await !self.downloadedStickers.contains(await self.emojis[i].name) else { continue }
						await self.download(emoji: self.emojis[i], skipStoreIndex: true)
						let _ = await MainActor.run { self.downloadedStickers.insert(self.emojis[i].name) }
						if await i == self.emojis.count {
							Task { @MainActor in
								self.storeDownloadedIndexes()
							}
						}
					}
				}
			}
		}
		
		print(Date.now.timeIntervalSince(start))
	}
	
	@MainActor
	func deleteAllStickers() {
		for i in emojis.indices {
			guard downloadedStickers.contains(emojis[i].name) else { continue }
			delete(emoji: emojis[i], skipStoreIndex: true)
		}
		downloadedStickers = []
		storeDownloadedIndexes()
	}
	
	private func storeDB(data: Data) {
		try! data.write(to: EmojiHoarder.localEmojiDB)
	}
	
	func resetAllIndexes() {
		trie.root = TrieNode()
		trie.dict = [:]
		trie.wordlist = []
		try? FileManager.default.removeItem(at: EmojiHoarder.localEmojiDB)
		try? FileManager.default.removeItem(at: EmojiHoarder.localTrie)
		try? FileManager.default.removeItem(at: EmojiHoarder.localTrieDict)
		
		downloadedStickers = []
		UserDefaults.standard.removeObject(forKey: "downloadedEmojis")
		letterStats = []
	}
	
	private func saveTrie() {
		guard let dataDict = try? encoder.encode(trie.dict) else {
			fatalError("failed to encode trie dict")
		}
		try! dataDict.write(to: EmojiHoarder.localTrieDict)
	}
	
	private func loadTrie() {
		guard FileManager.default.fileExists(atPath: EmojiHoarder.localTrieDict.path()) else { return }
		guard let dataDict = try? Data(contentsOf: EmojiHoarder.localTrieDict) else { return }
		guard let decodedDict = try? decoder.decode([String:Emoji].self, from: dataDict) else {
			fatalError("failed to decode dict")
		}
		self.trie.dict = decodedDict
	}
	
	func buildTrie() {
		let start = Date().timeIntervalSince1970
		for emoji in emojis {
//			trie.insewrt(word: emoji.name)
			trie.dict[emoji.name] = emoji
		}
		buildDownloadedEmojis()
		saveTrie()
		generateLetterStats()
		print("done building trie in", Date().timeIntervalSince1970-start)
	}
	
	func buildDownloadedEmojis() {
		if let data = UserDefaults.standard.data(forKey: "downloadedEmojis"),
		   let decoded = try? decoder.decode(Set<String>.self, from: data) {
			downloadedStickers = decoded
		} else {
			downloadedStickers = []
			if let files = try? FileManager.default.contentsOfDirectory(atPath: EmojiHoarder.container.path) {
				for file in files {
					let name = String(file.split(separator: ".")[0])
					downloadedStickers.insert(name)
				}
			}
			return
		}
	}
	
	func storeDownloadedIndexes() {
		UserDefaults.standard.set(try! encoder.encode(downloadedStickers), forKey: "downloadedEmojis")
	}
	
//	nonisolated
	private func loadLocalDB() -> [Emoji] {
		if let localEmojiDB = try? Data(contentsOf: EmojiHoarder.localEmojiDB) {
			let decoded = try! decoder.decode([Emoji].self, from: localEmojiDB)
			return decoded
		}
		return []
	}
	
	nonisolated
	private func loadRemoteDB() async {
		async let fetched = self.fetchRemoteDB()
		if let fetched = await fetched {
			await MainActor.run {
				withAnimation(.snappy) { self.emojis = fetched }
			}
		}
	}
	
	nonisolated
	private func fetchRemoteDB() async -> [Emoji]? {
		do {
			async let (data, _) = try URLSession.shared.data(from: endpoint)
			let decoded: [SlackResponse] = try await decoder.decode([SlackResponse].self, from: await data)
			try await storeDB(data: await data)
			return await SlackResponse.toEmojis(from: decoded)
		} catch {
			print(error.localizedDescription)
			return nil
		}
	}
	
	private func refreshDB() async {
		guard let fetched = await self.fetchRemoteDB() else {
			let local = loadLocalDB()
			await MainActor.run {
				emojis = local
				buildTrie()
			}
			return
		}
		await MainActor.run {
			withAnimation(.snappy) { self.emojis = fetched }
			buildTrie()
		}
	}
	
	nonisolated func download(emoji: any StickerProtocol, skipStoreIndex: Bool = false) async {
		try? await emoji.downloadImage()
		await MainActor.run {
			if !skipStoreIndex {
				let _ = withAnimation(.snappy) {
					self.downloadedStickers.insert(emoji.name)
				}
				self.storeDownloadedIndexes()
			}
			if !skipStoreIndex { Haptic.success.trigger() }
		}
	}
	
	@MainActor
	func delete(emoji: any StickerProtocol, skipStoreIndex: Bool = false) {
		emoji.deleteImage()
		if !skipStoreIndex {
			let _ = withAnimation(.snappy) {
				downloadedStickers.remove(emoji.name)
			}
			storeDownloadedIndexes()
		}
		if !skipStoreIndex { Haptic.heavy.trigger() }
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
}
