//
//  StickerBrowserViewController.swift
//  StickerSlackiMessageApp
//
//  Created by neon443 on 30/07/2026.
//

import Foundation
import UIKit
import Messages
import SwiftUI

class StickerBrowserViewController: MSStickerBrowserViewController {
	var emojiHoarder: EmojiHoarder!
	var pack: EmojiPack?
	var msStickers: [MSSticker] = []
	
	init(emojiHoarder: EmojiHoarder, pack: EmojiPack?) {
		self.emojiHoarder = emojiHoarder
		self.pack = pack
		
		super.init(stickerSize: .small)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func reload() {
		msStickers = []
		let names: [String]
		if let pack {
			names = emojiHoarder.downloadedStickers.intersection(pack.items).sorted()
		} else {
			names = emojiHoarder.downloadedStickers.sorted()
		}
		for name in names {
			guard let emoji = emojiHoarder.trie.dict[name],
				  let msSticker = emoji.msSticker else { continue }
			msStickers.append(msSticker)
		}
		stickerBrowserView.reloadData()
	}
	
	override func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
		return msStickers.count
	}
	
	override func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
		return msStickers[index]
	}
}
