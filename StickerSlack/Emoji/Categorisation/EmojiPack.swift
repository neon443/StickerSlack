//
//  EmojiPack.swift
//  StickerSlack
//
//  Created by neon443 on 28/10/2025.
//

import Foundation

struct EmojiPack: Identifiable, Codable {
	var id: UUID
	var name: String
	var description: String
	var emojiNames: [String]
}

extension EmojiPack {
	static func new() -> EmojiPack {
		EmojiPack(
			id: UUID(),
			name: "New Pack",
			description: "Created on \(Date().formatted())",
			emojiNames: []
		)
	}
}
