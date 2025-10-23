//
//  SlackResponse.swift
//  StickerSlack
//
//  Created by neon443 on 15/10/2025.
//

import Foundation

struct SlackResponse: Codable {
	var name: String
	var imageUrl: String
	var alias: String?
	
	
	static func toEmojis(from: [SlackResponse]) -> [Emoji] {
		return from.map { ApiEmoji(name: $0.name, url: $0.imageUrl).toEmoji() }
	}
}
