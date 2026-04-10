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
	
	init(id: UUID, name: String, description: String, items: [String]) {
		self.id = id
		self.name = name
		self.description = description
		self.items = items
	}
	
	init(fromShareLink url: URL) {
		guard url.scheme == "stickerslack" && url.safeHost == "shared.pack" else { fatalError("invalid share url") }
		guard let components = URLComponents(string: url.absoluteString),
			  let queryItems = components.queryItems else { fatalError("no query items or components") }
		
		self.id = UUID()
		self.name = ""
		self.description = ""
		self.items = []

		for item in queryItems {
			guard let value = item.value else { fatalError("nil value for param \(item.name)") }
			
			switch item.name {
			case "id":
				if let uuid = UUID(uuidString: value) {
					self.id = uuid
				}
			case "name":
				self.name = value
			case "description":
				self.description = value
			case "items":
				if let data = Data(base64Encoded: value),
				   let decoded = try? JSONDecoder().decode([String].self, from: data) {
					self.items = decoded
				}
			default:
				fatalError("unrecognised parameter in share link")
			}
		}
	}
	
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
		var url = URL(string: "stickerslack://shared.pack/")!
		
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
