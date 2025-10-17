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
	
//	func toEmojis() -> [Emoji] {
//		let initialMap = emoji.map {
//			Emoji(name: $0.key, url: $0.value)
//		}
//		return initialMap.map {
//			var ret = $0
//			if ret.urlString.prefix(6) == "alias:" {
//				if let orig = initialMap.first(where: {
//					$0.name == "\(ret.urlString.dropFirst(6))"
//				}) {
//					ret.urlString = orig.urlString
//				}
//			}
//			return ret
//		}
//	}
}
