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
	
	static func toEmojis(from response: [SlackResponse]?) -> [Emoji]? {
		guard let response else { return nil }
		return response.map { item in
			Emoji(
				name: item.name,
				url: URL(string: item.imageUrl)!,
				id: item.id
			)
		}
	}
}
