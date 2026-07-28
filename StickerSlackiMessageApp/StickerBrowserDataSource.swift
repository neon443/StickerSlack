//
//  StickerBrowserDataSource.swift
//  StickerSlackiMessageExtension
//
//  Created by neon443 on 29/10/2025.
//

import Foundation
import Messages

class StickerBrowserDataSource: NSObject, MSStickerBrowserViewDataSource {
	let pack: EmojiPack?
	var msStickers: [MSSticker] = []
	
	init(hoarder: EmojiHoarder, pack: EmojiPack?) {
		self.pack = pack
		super.init()
		Task {
			await hoarder.buildDownloadedStickers()
			for emojiName in hoarder.downloadedStickers {
				if let pack {
					guard pack.items.contains(emojiName) else { continue }
				}
				guard let emoji = hoarder.trie.dict[emojiName],
					  let msSticker = emoji.msSticker else { continue }
				self.msStickers.append(msSticker)
			}
		}
	}
	
	func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
		return msStickers.count
	}
	
	func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
		return msStickers[index]
	}
}
