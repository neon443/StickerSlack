//
//  StickerBrowserDataSource.swift
//  StickerSlackiMessageExtension
//
//  Created by neon443 on 29/10/2025.
//

import Foundation
import Messages

class StickerBrowserDataSource: NSObject, MSStickerBrowserViewDataSource {
	var hoarder: EmojiHoarder = EmojiHoarder(localOnly: true, skipIndex: true)
	
	var emojis: [MSSticker] = []
	
	func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
		guard emojis.isEmpty else { return emojis.count }
		for emoji in hoarder.emojis {
			guard let sticker = emoji.sticker else { continue }
			emojis.append(sticker)
		}
		return emojis.count
	}
	
	func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
		return emojis[index]
	}
}
