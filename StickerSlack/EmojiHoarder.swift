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
	private let endpoint: URL = URL(string: "https://slack.com/api/emoji.list")!
	@Published var kys = ""
	
	@Published var testBundle: SlackResponse
	
	init() {
		self.kys = ""
		
		guard let testURL = Bundle.main.url(forResource: "testData", withExtension: "json") else {
			fatalError("")
		}
		guard let data = try? Data(contentsOf: testURL) else {
			self.testBundle = SlackResponse(ok: false, emoji: [:])
			return
		}
		guard let decoded = try? JSONDecoder().decode(SlackResponse.self, from: data) else {
			fatalError("couldnt decode :sob:")
		}
		self.testBundle = decoded
	}
}
