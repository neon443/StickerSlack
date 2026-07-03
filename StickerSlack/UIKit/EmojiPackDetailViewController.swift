//
//  EmojiPackDetailViewController.swift
//  StickerSlack
//
//  Created by neon443 on 03/07/2026.
//

import Foundation
import UIKit


class EmojiPackDetailViewController: UINavigationController {
	var hoarder: EmojiHoarder
	var pack: EmojiPack
	let collectionView: EmojiCollectionView
	
	init(with hoarder: EmojiHoarder, andPack pack: EmojiPack) {
		self.hoarder = hoarder
		self.pack = pack
		self.collectionView = EmojiCollectionView(
			hoarder: hoarder,
			items: pack.items,
			width: 75,
			style: .full
		)
		super.init(rootViewController: collectionView)
		
		let editButton = UIBarButtonItem(systemItem: .edit)
		let downloadButton = UIBarButtonItem(
			image: UIImage(systemName: "arrow.down"),
			style: .plain,
			target: nil,
			action: nil
		)
		let shareButton = UIBarButtonItem(
			image: UIImage(systemName: "square.and.arrow.up"),
			style: .plain,
			target: nil,
			action: nil
		)
		collectionView.navigationItem.title = "HI"
		collectionView.toolbarItems = [editButton, downloadButton, shareButton]
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(packChanged),
			name: EmojiHoarder.NotifCategory.emojiPack(pack.id).name,
			object: nil
		)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func packChanged(_ notification: Notification) {
		if notification.name == EmojiHoarder.NotifCategory.emojiPack(pack.id).name {
			print("ooh its this pack")
			guard let updatedPack = hoarder.emojiPacks.first(where: { $0.id == pack.id }) else { return }
			self.pack = updatedPack
			collectionView.refreshUI(with: pack.items)
		} else {
			print("diff one")
		}
	}
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		collectionView.setEditing(editing, animated: animated)
	}
}
