//
//  SlackResponse.swift
//  StickerSlack
//
//  Created by neon443 on 15/10/2025.
//

import Foundation

struct SlackResponse: Codable {
	var ok: Bool
	var emoji: [String:String]
	
	func toEmojis() -> [Emoji] {
		return emoji.map {
			Emoji(name: $0.key, url: $0.value)
		}
	}
}

struct Emoji: Codable, Hashable {
	var name: String
	var url: String
	
	init(name: String, url: String) {
		self.name = name
		self.url = url
	}
}
