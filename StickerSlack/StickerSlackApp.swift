//
//  StickerSlackApp.swift
//  StickerSlack
//
//  Created by neon443 on 15/10/2025.
//

import SwiftUI

@main
struct StickerSlackApp: App {
	@ObservedObject var emojiHoarder: EmojiHoarder = EmojiHoarder()
	@ObservedObject var gifhoarder: GifHoarder = GifHoarder()
	
	@State var importingEmojiPack: Bool = false
	@State var pack: EmojiPack = .new()
	
	var body: some Scene {
		WindowGroup {
			ContentView(emojiHoarder: emojiHoarder, gifhoarder: gifhoarder)
				.onOpenURL { url in
					importingEmojiPack = true
					pack = EmojiPack(fromShareLink: url)
					NotificationCenter.default.post(name: .didImportPack, object: pack)
				}
				.sheet(isPresented: $importingEmojiPack) {
					EmojiPackImporterView(emojiHoarder: emojiHoarder, pack: $pack)
				}
		}
	}
}

extension Notification.Name {
	static let didImportPack = Self("didImportNote")
}
