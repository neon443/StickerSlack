//
//  SlackResponse.swift
//  StickerSlack
//
//  Created by neon443 on 15/10/2025.
//

import Foundation

struct SlackResponse: Identifiable, Codable {
	var type: String
	var id: UUID
	var name: String
	var imageUrl: String
	var alias: String?
	var expiration: Date
	
	static func toEmojis(from response: [SlackResponse]?) -> [Emoji]? {
		guard let response else { return nil }
		return response.map { ApiEmoji(name: $0.name, url: $0.imageUrl).toEmoji() }
	}
}
