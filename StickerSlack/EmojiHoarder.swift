//
//  EmojiHoarder.swift
//  StickerSlack
//
//  Created by neon443 on 15/10/2025.
//

import Foundation
import SwiftUI
import Combine

class EmojiHoarder: ObservableObject {
	private let endpoint: URL = URL(string: "https://cachet.dunkirk.sh/emojis")!
	
	@Published var emojis: [Emoji]
	
	init() {
		let data = try! Data(contentsOf: endpoint)
		let decoded: [SlackResponse] = try! JSONDecoder().decode([SlackResponse].self, from: data)
		self.emojis = decoded.map { Emoji(name: $0.name, url: $0.imageUrl) }
	}
}
