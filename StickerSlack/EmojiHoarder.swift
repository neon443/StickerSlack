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
	static let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.neon443.StickerSlack")!
	private let endpoint: URL = URL(string: "https://cachet.dunkirk.sh/emojis")!
	
	@Published var emojis: [Emoji]
	
	init() {
		guard let data = try? Data(contentsOf: endpoint) else { fatalError("cachet unreachable") }
		let decoded: [SlackResponse] = try! JSONDecoder().decode([SlackResponse].self, from: data)
		self.emojis = decoded.map { ApiEmoji(name: $0.name, url: $0.imageUrl).toEmoji() }
//		Task {
//			for i in emojis.indices {
//				emojis[i].image = try? await emojis[i].loadImage()
//			}
//		}
	}
	
//	func storeStickers
}
