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
		let initialMap = emoji.map {
			Emoji(name: $0.key, url: $0.value)
		}
		initialMap.map {
			var ret = $0
			ret.urlString = ret.urlString.prefix(6) == "alias:" ? initialMap.first(where: { $0.name == ret.name })!.url : ret.urlString
			return ret
		}
		return emoji.map {
			Emoji(name: $0.key, url: $0.value)
		}
	}
}

struct Emoji: Codable, Hashable {
	var name: String
	var urlString: String
	var url: URL {
		return URL(string: urlString) ?? URL(string: "https://")!
	}
	
	init(name: String, url: String) {
		self.name = name
		self.urlString = url
	}
}
