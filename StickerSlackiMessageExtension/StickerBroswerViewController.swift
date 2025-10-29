//
//  StickerBroswerViewController.swift
//  StickerSlackiMessageExtension
//
//  Created by neon443 on 29/10/2025.
//

import Foundation
import UIKit
import Messages

class StickerBroswerViewController: MSStickerBrowserViewController {
	var hoarder: EmojiHoarder = EmojiHoarder()
	
	var emojis: [Emoji] = []
	
	override func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
		emojis = hoarder.emojis.filter { $0.isLocal }
		return emojis.count
	}
	
	override func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
		return emojis[index].sticker
	}
}
