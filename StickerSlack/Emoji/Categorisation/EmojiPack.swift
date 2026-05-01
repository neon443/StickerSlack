//
//  EmojiPack.swift
//  StickerSlack
//
//  Created by neon443 on 28/10/2025.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct EmojiPack: Identifiable, Codable, Equatable {
	var id: UUID
	var name: String
	var description: String
	var items: [String]
	
	init(id: UUID, name: String, description: String, items: [String]) {
		self.id = id
		self.name = name
		self.description = description
		self.items = items
	}
	
	init?(fromShareLink url: URL) {
		guard url.safeHost == "shared.pack" ||
						url.safeHost == "stickerslack.neon443.xyz" ||
						url.safeHost == "stickerslack.nihaals.me" else {
					return nil
				}
		guard let created = EmojiPack.createFrom(url: url) else {
			return nil
		}
		self = created
	}
	
	static func createFrom(url: URL) -> EmojiPack? {
		var pack: EmojiPack = .new()
		
		guard let components = URLComponents(string: url.absoluteString),
			  let queryItems = components.queryItems else {
			print("no query items or components")
			return nil
		}
		
		for item in queryItems {
			guard let value = item.value else { fatalError("nil value for param \(item.name)") }
			
			switch item.name {
			case "id":
				if let uuid = UUID(uuidString: value) {
					pack.id = uuid
				}
			case "name":
				pack.name = value
			case "description":
				pack.description = value
			case "items":
				if let data = Data(base64Encoded: value),
				   let decoded = try? JSONDecoder().decode([String].self, from: data) {
					pack.items = decoded
				}
			default:
				print("unrecognised parameter in share link")
				return nil
			}
		}
		return pack
	}
	
	enum ShareURLTypes {
		case stickerslack
		case neon443
		case nihaals
	}
	
	mutating func add(_ newItem: String) {
		guard !items.contains(newItem) else { return }
		self.items.append(newItem)
	}
	
	mutating func remove(_ itemToRemove: String) {
		guard let index = self.items.firstIndex(where: { $0 == itemToRemove }) else {
			return
		}
		self.items.remove(at: index)
	}
	
	mutating func addRemove(_ item: String) {
		if items.contains(item) {
			self.remove(item)
		} else {
			self.add(item)
		}
	}
	
	nonisolated func downloadAll(hoarder: EmojiHoarder) async {
		let dict = await hoarder.trie.dict
		var emojis: [Emoji] = []
		for item in items {
			if let foundEmoji = dict[item] {
				emojis.append(foundEmoji)
			}
		}
		await hoarder.batchDownload(emojis: emojis)
	}
	
	nonisolated func deleteAll(hoarder: EmojiHoarder) async {
		let dict = await hoarder.trie.dict
		var emojis: [Emoji] = []
		for item in items {
			if let foundEmoji = dict[item] {
				emojis.append(foundEmoji)
			}
		}
		await hoarder.batchDelete(emojis: emojis)
	}
	
	func shareLink() -> URL {
//		var url = URL(string: "stickerslack://shared.pack/")!
		var url = URL(string: "https://stickerslack.neon443.xyz/share/")!
		
		let data = try! JSONEncoder().encode(items)
		let queries: [URLQueryItem] = [
			.init(name: "id", value: id.uuidString),
			.init(name: "name", value: name),
			.init(name: "description", value: description),
			.init(name: "items", value: data.base64EncodedString())
		]
		
		var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
		components!.queryItems = queries
		url = components!.url!
		return url
	}
	
	func allDownloaded(in hoarder: EmojiHoarder) -> Bool {
		guard !items.isEmpty else { return false }
		return Set(self.items).isSubset(of: hoarder.downloadedStickers)
	}
	
	func downloadedFraction(in hoarder: EmojiHoarder) -> Double {
		guard !items.isEmpty else { return 0 }
		guard !allDownloaded(in: hoarder) else { return 1 }
		let common = hoarder.downloadedStickers.intersection(items)
		return Double(common.count)/Double(items.count)
	}
}

extension EmojiPack {
	static func new(withItems items: [String] = []) -> EmojiPack {
		EmojiPack(
			id: UUID(),
			name: "New Pack",
			description: "Created on \(Date().formatted())",
			items: items
		)
	}
}
