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
	
	func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
		return hoarder.emojis.filter { $0.isLocal }.count
	}
	
	func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
		return hoarder.emojis.filter { $0.isLocal }[index].sticker
	}
}
