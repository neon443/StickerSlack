//
//  StickerBrowserDataSource.swift
//  StickerSlackiMessageExtension
//
//  Created by neon443 on 29/10/2025.
//

import Foundation
import Messages

class StickerBrowserDataSource: NSObject, MSStickerBrowserViewDataSource {
	var hoarder: EmojiHoarder = EmojiHoarder()
	
	var emojis: [MSSticker] = []
	
	func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
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
