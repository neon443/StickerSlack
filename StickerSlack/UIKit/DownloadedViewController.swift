//
//  DownloadedViewController.swift
//  StickerSlack
//
//  Created by neon443 on 02/07/2026.
//

import Foundation
import UIKit

class DownloadedViewController: UINavigationController, UINavigationControllerDelegate {
	let downloadedView: EmojiCollectionView
	var emojiHoarder: EmojiHoarder
	
	init(emojiHoarder: EmojiHoarder) {
		self.emojiHoarder = emojiHoarder
		downloadedView = EmojiCollectionView(
			hoarder: emojiHoarder,
			items: emojiHoarder.downloadedStickersArr,
			width: 75,
			style: .plainWithMenu
		)
		downloadedView.navigationItem.title = "Downloaded"
		downloadedView.collectionView.dragInteractionEnabled = false
		super.init(rootViewController: downloadedView)
		
		refreshUI()
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(refreshUI),
			name: EmojiHoarder.NotifCategory.downloadedEmojis.name,
			object: nil
		)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func refreshUI() {
		downloadedView.refreshUI(with: emojiHoarder.downloadedStickersArr)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
}
