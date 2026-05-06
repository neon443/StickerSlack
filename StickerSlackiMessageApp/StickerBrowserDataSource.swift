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
	
	var msStickers: [MSSticker] = []
	var emojis: [Emoji] = []
	
	override init() {
		super.init()
		var emojis: [Emoji] = []
		guard let files = try? FileManager.default.contentsOfDirectory(atPath: EmojiHoarder.container.safePath) else { return }
		
		for file in files {
			guard file.contains(".png") ||
					file.contains(".jpg") ||
					file.contains(".gif") else { continue }
			let name = String(file.split(separator: ".")[0])
			if let emoji = hoarder.trie.dict[name] {
				emojis.append(emoji)
			} else {
				print(
					"name, emoji has value, mssticker has value:",
					name,
					hoarder.trie.dict[name] != nil,
					hoarder.trie.dict[name]?.msSticker != nil
				)
			}
		}
		emojis.sort(by: { $0.name > $1.name })
		for emoji in emojis {
			guard let msSticker = emoji.msSticker else { continue }
			msStickers.append(msSticker)
		}
		
		print(msStickers.count, "init")
	}
	
	func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
		print(msStickers.count, "numberofstickers")
		return msStickers.count
	}
	
	func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
		return msStickers[index]
	}
}
