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
	var emptyView: UIViewController
	
	init(emojiHoarder: EmojiHoarder, pack: EmojiPack?) {
		self.emojiHoarder = emojiHoarder
		self.pack = pack
		self.emptyView = UIHostingController(
			rootView: EmptyCollectionView(
				title: "None Downloaded",
				details: "This emoji pack contains no downloaded emojis",
				systemImage: "square.slash.fill"
			)
		)
		emptyView.view.tintColor = #colorLiteral(red: 0.7490000129, green: 0.3529999852, blue: 0.949000001, alpha: 1)
		super.init(stickerSize: .small)
		reload()
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
		setEmptyViewTo(visible: msStickers.isEmpty)
	}
	
	func setEmptyViewTo(visible: Bool) {
		if visible {
			emptyView.willMove(toParent: self)
			self.addChild(emptyView)
			self.view.addSubview(emptyView.view)
			emptyView.view.translatesAutoresizingMaskIntoConstraints = false
			NSLayoutConstraint.activate([
				emptyView.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
				emptyView.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
				emptyView.view.topAnchor.constraint(equalTo: self.view.topAnchor)
			])
			emptyView.didMove(toParent: self)
		} else {
			emptyView.willMove(toParent: nil)
			emptyView.removeFromParent()
			emptyView.view.removeFromSuperview()
			emptyView.didMove(toParent: nil)
		}
	}
	
	override func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
		return msStickers.count
	}
	
	override func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
		return msStickers[index]
	}
}
