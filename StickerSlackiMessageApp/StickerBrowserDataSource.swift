//
//  StickerBrowserDataSource.swift
//  StickerSlackiMessageExtension
//
//  Created by neon443 on 29/10/2025.
//

import Foundation
import Messages

class StickerBrowserDataSource: NSObject, MSStickerBrowserViewDataSource {
	let emojiHoarder: EmojiHoarder
	let pack: EmojiPack?
	var msStickers: [MSSticker] = []
	
	init(hoarder: EmojiHoarder, pack: EmojiPack?) {
		self.emojiHoarder = hoarder
		self.pack = pack
		super.init()
		DispatchQueue.main.asyncAfter(deadline: .now()+3) {
			self.load()
		}
	}
	
	func load() {
		Task {
			await emojiHoarder.buildDownloadedStickers()
			for emojiName in emojiHoarder.downloadedStickers {
				if let pack {
					guard pack.items.contains(emojiName) else { continue }
				}
				guard let emoji = emojiHoarder.trie.dict[emojiName],
					  let msSticker = emoji.msSticker else { continue }
				self.msStickers.append(msSticker)
			}
			print("finished loading", msStickers.count)
		}
	}
	
	func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
		print(msStickers.count)
		return msStickers.count
	}
	
	func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
		return msStickers[index]
	}
}
