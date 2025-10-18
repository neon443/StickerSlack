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
//		guard let testURL = Bundle.main.url(forResource: "testData", withExtension: "json") else {
//			fatalError("")
//		}
//		guard let data = try? Data(contentsOf: testURL) else {
//			self.testBundle = SlackResponse(ok: false, emoji: [:])
//			return
//		}
//		guard let decoded = try? JSONDecoder().decode(SlackResponse.self, from: data) else {
//			fatalError("couldnt decode :sob:")
//		}
//		self.testBundle = decoded
		
		let data = try! Data(contentsOf: endpoint)
		let decoded: [SlackResponse] = try! JSONDecoder().decode([SlackResponse].self, from: data)
		var emojis = decoded.prefix(100).map { Emoji(name: $0.name, url: $0.imageUrl) }
		for i in emojis.indices {
			emojis[i].grabImageSync()
		}
		self.emojis = emojis
//		Task {
//			for i in emojis.indices {
//				let newEmoji = await emojis[i].grabImage()
//				DispatchQueue.main.async {
//					self.emojis[i] = newEmoji
//					self.emojis = self.emojis
//				}
//			}
//		}
	}
}
