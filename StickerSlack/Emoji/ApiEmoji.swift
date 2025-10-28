//
//  Emoji.swift
//  StickerSlack
//
//  Created by neon443 on 17/10/2025.
//

import Foundation
import SwiftUI

protocol EmojiProtocol: Codable, Hashable {
	var name: String { get set }
	var urlString: String { get set }
}

struct ApiEmoji: EmojiProtocol {
	var name: String
	var urlString: String
	
	var url: URL {
		return URL(string: urlString) ?? URL(string: "https://")!
	}
	
	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.init(
			name: try container.decode(String.self, forKey: .name),
			url: try container.decode(String.self, forKey: .urlString)
		)
	}
	
	init(
		name: String,
		url: String,
	) {
		self.name = name
		self.urlString = url
	}
	
	enum CodingKeys: CodingKey {
		case name
		case urlString
	}
	
	func toEmoji(withID: UUID = UUID()) -> Emoji {
		return Emoji(apiEmoji: self, id: withID)
	}
	
	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.name, forKey: .name)
		try container.encode(self.urlString, forKey: .urlString)
	}
}

