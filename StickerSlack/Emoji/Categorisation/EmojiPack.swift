//
//  EmojiPack.swift
//  StickerSlack
//
//  Created by neon443 on 28/10/2025.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct EmojiPack: Identifiable, Codable {
	var id: UUID
	var name: String
	var description: String
	var items: [String]
//	var items: [EmojiPack.Item]
	
//	struct Item: Identifiable, Codable, Equatable {
//		var id: UUID
//		var name: String
//	}
	
	mutating func add(_ newItem: String) {
		guard !items.contains(newItem) else { return }
		withAnimation {
			self.items.append(newItem)
		}
	}
	
	mutating func remove(_ itemToRemove: String) {
		guard let index = self.items.firstIndex(where: { $0 == itemToRemove }) else {
			return
		}
		let _ = withAnimation {
			self.items.remove(at: index)
		}
	}
	
	func shareLink() -> URL {
		let scheme = URL(string: "stickerslack://")!
		var url: URL = scheme.appendingPathComponent("pack", conformingTo: .directory)
		
		let data = try! JSONEncoder().encode(items)
		let queries: [URLQueryItem] = [
			.init(name: "id", value: id.uuidString),
			.init(name: "name", value: name),
			.init(name: "description", value: description),
			.init(name: "items", value: data.base64EncodedString())
		]
		url = url.appending(queryItems: queries)
		print(url.path(percentEncoded: true))
		return url
	}
}

extension EmojiPack {
	static func new() -> EmojiPack {
		EmojiPack(
			id: UUID(),
			name: "New Pack",
			description: "Created on \(Date().formatted())",
			items: []
		)
	}
}
