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
	
	init() {
		withAnimation { self.emojis = loadLocalDB() }
		withAnimation { self.filteredEmojis = self.emojis }
		
		Task(priority: .high) {
			if let fetched = await self.fetchRemoteDB() {
				withAnimation { self.emojis = fetched }
				withAnimation { self.filteredEmojis = fetched }
			}
		}
	}
	
	func storeStickers(_ toStore: [UUID]) {
		for stickerId in toStore {
			print(stickerId)
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
	
	func fetchRemoteDB() async -> [Emoji]? {
		do {
			let (data, _) = try await URLSession.shared.data(from: endpoint)
			decoder.dateDecodingStrategy = .iso8601
			let decoded: [SlackResponse] = try! decoder.decode([SlackResponse].self, from: data)
			storeDB(data: data)
			return SlackResponse.toEmojis(from: decoded)
		} catch {
			print(error.localizedDescription)
			fatalError()
		}
	}
	
	func refreshDB(withCallback callback: (() -> Void)? = nil) {
		Task {
			guard let fetched = try? await fetchRemoteDB() else { return }
			withAnimation { self.emojis = fetched }
			withAnimation { self.filteredEmojis = fetched }
			if let callback {
				callback()
			}
		}
	}
	
	func filterEmojis(by searchTerm: String) {
		guard !searchTerm.isEmpty else {
			withAnimation(.interactiveSpring) { self.filteredEmojis = emojis }
			return
		}
		Task {
			let filtered = emojis.filter { $0.name.localizedCaseInsensitiveContains(searchTerm) }
			DispatchQueue.main.async {
				withAnimation(.interactiveSpring) { self.filteredEmojis = filtered }
			}
		}
	}
}
