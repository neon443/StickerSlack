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
	
	static var test: EmojiPack {
		EmojiPack(
			id: UUID(),
			name: "test pack",
			description: "neon443's debug emoji pack",
			emojiNames: [
				"pf",
				"heavysob",
				"yay",
				"skulk",
				"loll",
				"bleh",
				"uhh",
				"communist"
			]
		)
	}
}
