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
	
	@Published var emojis: [Emoji] = []
	
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
		try! JSONEncoder().encode(emojis).write(to: EmojiHoarder.localEmojiDB)
	}
	
	func loadLocalDB() -> [Emoji] {
		if let localEmojiDB = try? Data(contentsOf: EmojiHoarder.localEmojiDB) {
			let decoded = try! JSONDecoder().decode([Emoji].self, from: localEmojiDB)
			return decoded
		}
		return []
	}
	
	func fetchRemoteDB() -> [Emoji]? {
		guard let data = try? Data(contentsOf: endpoint) else { fatalError("cachet unreachable") }
		let decoded: [SlackResponse] = try! JSONDecoder().decode([SlackResponse].self, from: data)
		return SlackResponse.toEmojis(from: decoded)
	}
}
