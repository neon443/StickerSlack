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
	static let localEmojiDB: URL = EmojiHoarder.container.appendingPathExtension("localEmojiDB.json")
	private let endpoint: URL = URL(string: "https://cachet.dunkirk.sh/emojis")!
	private let encoder = JSONEncoder()
	private let decoder = JSONDecoder()
	
	@Published var emojis: [Emoji] = []
	@Published var filteredEmojis: [Emoji] = []
	@Published var prefix: Int = 100
	
	init() {
		guard let fetched = fetchRemoteDB() else {
			self.emojis = loadLocalDB()
			return
		}
		
		self.emojis = fetched
	}
	
	func storeStickers(_ toStore: [UUID]) {
		for stickerId in toStore {
			print(stickerId)
		}
	}
	
	func storeDB() {
		try! encoder.encode(emojis).write(to: EmojiHoarder.localEmojiDB)
	}
	
	func loadLocalDB() -> [Emoji] {
		if let localEmojiDB = try? Data(contentsOf: EmojiHoarder.localEmojiDB) {
			let decoded = try! decoder.decode([Emoji].self, from: localEmojiDB)
			return decoded
		}
		return []
	}
	
	func fetchRemoteDB() -> [Emoji]? {
		guard let data = try? Data(contentsOf: endpoint) else { fatalError("cachet unreachable") }
		decoder.dateDecodingStrategy = .iso8601
		let decoded: [SlackResponse] = try! decoder.decode([SlackResponse].self, from: data)
		return SlackResponse.toEmojis(from: decoded)
	}
	
	func setPrefix(to: Int) {
		filterEmojis(by: "")
		filteredEmojis = Array(filteredEmojis.prefix(prefix))
	}
	
	func filterEmojis(by searchTerm: String) {
		guard !searchTerm.isEmpty else {
			self.filteredEmojis = []
			return
		}
		Task {
			let filtered = emojis.filter { $0.name.localizedCaseInsensitiveContains(searchTerm) }
			DispatchQueue.main.async {
				self.filteredEmojis = filtered
			}
		}
	}
}
