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
	@Published var filteredEmojis: [Emoji] = []
	@Published var prefix: Int = 100
	
	init(localOnly: Bool = false) {
		let localDB = loadLocalDB()
		withAnimation { self.emojis = localDB }
		withAnimation { self.filteredEmojis = localDB }
		
		guard !localOnly else { return }
		Task.detached {
			await self.loadRemoteDB()
		}
	}
	
	func storeStickers(_ toStore: [UUID]) {
		for stickerId in toStore {
			print(stickerId)
		}
	}
	
	func deleteAllStickers() async {
		await withTaskGroup { group in
			for emoji in emojis {
				group.addTask {
					guard await emoji.isLocal else { return }
					await emoji.deleteImage()
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
			withAnimation { self.filteredEmojis = fetched }
		}
	}
	
	func fetchRemoteDB() async -> [Emoji]? {
		do {
			async let (data, _) = try URLSession.shared.data(from: endpoint)
			decoder.dateDecodingStrategy = .iso8601
			let decoded: [SlackResponse] = try decoder.decode([SlackResponse].self, from: await data)
			try storeDB(data: await data)
			return SlackResponse.toEmojis(from: decoded)
		} catch {
			print(error.localizedDescription)
			return nil
		}
	}
	
	func refreshDB() async {
		guard let fetched = await self.fetchRemoteDB() else { return }
		DispatchQueue.main.async {
			withAnimation { self.emojis = fetched }
			withAnimation { self.filteredEmojis = fetched }
		}
	}
	
	func filterEmojis(by searchTerm: String) {
		guard !searchTerm.isEmpty else {
			withAnimation(.interactiveSpring) { self.filteredEmojis = Array(emojis) }
			return
		}
		Task.detached {
			let filtered = await self.emojis.filter { $0.name.localizedCaseInsensitiveContains(searchTerm) }
			DispatchQueue.main.async {
				withAnimation(.interactiveSpring) { self.filteredEmojis = Array(filtered) }
			}
		}
	}
	
	func filterEmojis(byCategory category: FilterCategory, searchTerm: String) {
		guard category != .none else {
			filterEmojis(by: searchTerm)
			return
		}
		self.filterEmojis(by: searchTerm)
		DispatchQueue.main.async {
			switch category {
			case .none:
				fallthrough
			case .downloaded:
				withAnimation(.interactiveSpring) { self.filteredEmojis = self.filteredEmojis.filter { $0.isLocal } }
			case .notDownloaded:
				withAnimation(.interactiveSpring) { self.filteredEmojis = self.filteredEmojis.filter { !$0.isLocal } }
			}
		}
	}
}
