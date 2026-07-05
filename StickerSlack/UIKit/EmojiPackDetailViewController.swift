//
//  EmojiPackDetailViewController.swift
//  StickerSlack
//
//  Created by neon443 on 03/07/2026.
//

import Foundation
import UIKit
import SwiftUI
import UniformTypeIdentifiers

class EmojiPackDetailViewController: UINavigationController {
	var hoarder: EmojiHoarder
	var pack: EmojiPack
	let collectionView: EmojiCollectionView
	var downloadButton: UIBarButtonItem
	var searchView: SearchViewController
	
	init(with hoarder: EmojiHoarder, andPack pack: EmojiPack) {
		self.hoarder = hoarder
		self.pack = pack
		self.collectionView = EmojiCollectionView(
			hoarder: hoarder,
			items: pack.items,
			width: 75,
			style: .full
		)
//		let suiView = SearchView(hoarder: hoarder, fromPackEditor: true)
//		self.searchView = UIHostingController(rootView: suiView)
		self.searchView = SearchViewController(emojiHoarder: hoarder, gridLayout: true)
		
		let adderSheetButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: nil, action: #selector(showSheet))
		let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(hideSheet))
		searchView.resultsView.navigationItem.leftBarButtonItem = cancelButton
		
		let editButton = collectionView.editButtonItem
		editButton.target = collectionView
		self.downloadButton = UIBarButtonItem(
			image: UIImage(systemName: "arrow.down"),
			style: .plain,
			target: nil,
			action: #selector(downloadAll)
		)
		let shareButton = UIBarButtonItem(
			image: UIImage(systemName: "square.and.arrow.up"),
			style: .plain,
			target: nil,
			action: #selector(share)
		)
		super.init(rootViewController: collectionView)
		collectionView.navigationItem.title = pack.name
		
//		collectionView.toolbarItems = [editButton, downloadButton, shareButton]
		collectionView.navigationItem.leftBarButtonItems = [editButton, adderSheetButton]
		collectionView.navigationItem.rightBarButtonItems = [shareButton, downloadButton]
		
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
		guard notification.name == EmojiHoarder.NotifCategory.emojiPack(pack.id).name else { return }
		guard let updatedPack = hoarder.emojiPacks.first(where: { $0.id == pack.id }) else { return }
		self.pack = updatedPack
		collectionView.navigationItem.title = pack.name
		collectionView.refreshUI(with: pack.items)
	}
	
	@objc func showSheet() {
		if let sheet = searchView.sheetPresentationController {
			sheet.detents = [.medium(), .large()]
			sheet.prefersScrollingExpandsWhenScrolledToEdge = false
			sheet.prefersEdgeAttachedInCompactHeight = true
			sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
			sheet.prefersGrabberVisible = true
		}
		self.present(self.searchView, animated: true)
	}
	
	@objc func hideSheet() {
		self.dismiss(animated: true)
	}
	
	@objc func downloadAll() {
		if !pack.allDownloaded(in: hoarder) {
//			downloading = true
		}
		Task {
			if pack.allDownloaded(in: hoarder) {
				await pack.deleteAll(hoarder: hoarder)
				self.downloadButton.image = UIImage(systemName: "arrow.down")
			} else {
				await pack.downloadAll(hoarder: hoarder)
				self.downloadButton.image = UIImage(systemName: "checkmark")
			}
		}
	}
	
	@objc func share() {
		let itemProvider = NSItemProvider(item: pack.shareLink() as NSURL, typeIdentifier: UTType.url.identifier)
		
		let config = UIActivityItemsConfiguration(itemProviders: [itemProvider])
		
		let shareSheet = UIActivityViewController(activityItemsConfiguration: config)
		
		present(shareSheet, animated: true)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.post(name: EmojiHoarder.NotifCategory.emojiPack(pack.id).name, object: nil)
	}
}
