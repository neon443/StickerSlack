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
	
	init(emojiHoarder: EmojiHoarder, pack: EmojiPack?) {
		self.emojiHoarder = emojiHoarder
		self.pack = pack
		super.init(stickerSize: .small)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
		if let pack {
			return emojiHoarder.downloadedStickers.union(pack.items).count
		} else {
			return emojiHoarder.downloadedStickers.count
		}
	}
	
	override func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
		let emojiName: String
		if let pack {
			emojiName = emojiHoarder.downloadedStickers.union(pack.items).sorted()[index]
		} else {
			emojiName = emojiHoarder.downloadedStickersArr[index]
		}
		guard let emoji = emojiHoarder.trie.dict[emojiName],
			  let msSticker = emoji.msSticker else {
			fatalError()
		}
		return msSticker
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		DispatchQueue.main.asyncAfter(deadline: .now()+3) {
			self.stickerBrowserView.reloadData()
		}
		return
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		stickerBrowserView.reloadData()
//		guard numberOfStickers(in: self.stickerBrowserView) != 0 else {
//			let swiftUIView = NoStickersView()
//			let hostingController = UIHostingController(rootView: swiftUIView)
//			hostingController.view.translatesAutoresizingMaskIntoConstraints = false
//			view.addSubview(hostingController.view)
//			
//			NSLayoutConstraint.activate([
//				hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//				hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//				hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
//				hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//			])
//			return
//		}
	}
}
