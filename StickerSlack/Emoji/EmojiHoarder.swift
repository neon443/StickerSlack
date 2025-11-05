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

class EmojiHoarder: ObservableObject {
	static let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.neon443.StickerSlack")!.appendingPathComponent("Library", conformingTo: .directory)
	static let localEmojiDB: URL = EmojiHoarder.container.appendingPathComponent("_localEmojiDB.json", conformingTo: .fileURL)
	private let endpoint: URL = URL(string: "https://cachet.dunkirk.sh/emojis")!
	private let encoder = JSONEncoder()
	private let decoder = JSONDecoder()
	
	@Published var emojis: [Emoji] = []
	
	@Published var trie: Trie = Trie()
	@Published var filteredEmojis: [String] = []
	@Published var downloadedEmojis: Set<String> = []
	@Published var searchTerm: String = ""
	
	init(localOnly: Bool = false) {
		let localDB = loadLocalDB()
		withAnimation { self.emojis = localDB }
		buildTrie()
		withAnimation { self.filteredEmojis = [] }
		
		guard !localOnly else { return }
		Task.detached {
			print("start loading remote db")
			await self.loadRemoteDB()
			print("end")
			await self.buildTrie()
		}
	}
	
	func storeStickers(_ toStore: [UUID]) {
		for stickerId in toStore {
			print(stickerId)
		}
	}
	
	func deleteAllStickers() async {
		await withTaskGroup { group in
			for i in emojis.indices {
				group.addTask {
					guard await self.emojis[i].isLocal else { return }
					await self.emojis[i].deleteImage()
					DispatchQueue.main.sync {
						self.emojis[i].refresh()
					}
				}
			}
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
		filteredEmojis = []
	}
	
	func buildTrie() {
		let start = Date().timeIntervalSince1970
		trie.root = TrieNode()
		for emoji in emojis {
			trie.insert(word: emoji.name, emoji: emoji)
		}
		buildTrieDict()
		print("done building trie in", Date().timeIntervalSince1970-start)
	}
	
	func buildTrieDict() {
		var dict: [String:Emoji] = [:]
		for emoji in emojis {
			dict[emoji.name] = emoji
		}
		self.trie.dict = dict
		buildDownloadedEmojis()
	}
	
	func buildDownloadedEmojis() {
		downloadedEmojis = []
		for emoji in emojis {
			guard emoji.isLocal else { continue }
			downloadedEmojis.insert(emoji.name)
		}
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
	
	func filterEmojis(by searchTerm: String) {
		withAnimation { filteredEmojis = trie.search(prefix: searchTerm) }
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
