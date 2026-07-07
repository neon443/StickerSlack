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
import Haptics

class EmojiPackDetailViewController: UIViewController {
	var hoarder: EmojiHoarder
	var pack: EmojiPack
	let collectionView: EmojiCollectionView
	
	var adderSheetButton: UIBarButtonItem!
	var downloadButton: UIAction!
	var shareButton: UIAction!
	
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
		self.searchView = SearchViewController(emojiHoarder: hoarder, gridLayout: true)
		
		super.init(nibName: nil, bundle: nil)
		self.addChild(collectionView)
		self.view.addSubview(collectionView.view)
		collectionView.view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			collectionView.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			collectionView.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			collectionView.view.topAnchor.constraint(equalTo: self.view.topAnchor),
			collectionView.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
		])
		collectionView.didMove(toParent: self)
		collectionView.onRemove = { removedItem in
			self.pack.items = self.collectionView.items
		}
		
		self.searchView.setOnTapCallback { selection in
			guard !self.pack.items.contains(selection) else {
				Haptic.error.trigger()
				return
			}
			self.pack.add(selection)
			Haptic.heavy.trigger()
			var newItems = self.collectionView.items
			newItems.append(selection)
			self.collectionView.refreshUI(with: newItems)
		}
		
		self.adderSheetButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(showSheet))
		
		let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(hideSheet))
		searchView.resultsView.navigationItem.rightBarButtonItem = doneButton
		
		self.shareButton = UIAction(title: "Share...", image: UIImage(systemName: "square.and.arrow.up")) { action in
			self.share()
		}
		self.downloadButton = UIAction(title: "Download", image: UIImage(systemName: "arrow.down")) { action in
			self.downloadButtonAction()
		}
		self.navigationItem.title = pack.name
		self.setToolbar(editing: false)
		
		collectionView.onEditChange = { self.setToolbar(editing: $0) }
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
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
		self.searchView.dismiss(animated: true)
	}
	
	@objc func downloadButtonAction() {
		if !pack.allDownloaded(in: hoarder) {
//			downloading = true
		}
		Task {
			if pack.allDownloaded(in: hoarder) {
				await pack.deleteAll(hoarder: hoarder)
				self.downloadButton.image = UIImage(systemName: "arrow.down")
				self.downloadButton.title = "Download"
			} else {
				await pack.downloadAll(hoarder: hoarder)
				self.downloadButton.image = UIImage(systemName: "trash")
				self.downloadButton.title = "Remove Download"
			}
			self.setToolbar(editing: false)
		}
	}
	
	@objc func share() {
		let itemProvider = NSItemProvider(item: pack.shareLink() as NSURL, typeIdentifier: UTType.url.identifier)
		let config = UIActivityItemsConfiguration(itemProviders: [itemProvider])
		let shareSheet = UIActivityViewController(activityItemsConfiguration: config)
		present(shareSheet, animated: true)
	}
	
	func setToolbar(editing: Bool) {
		let items: [UIBarButtonItem]
		if editing {
			if #available(iOS 26, *) {
				items = [self.collectionView.editButtonItem, .fixedSpace(), self.adderSheetButton]
			} else {
				items = [self.collectionView.editButtonItem, self.adderSheetButton]
			}
		} else {
			let dotdotdotButton = UIBarButtonItem(title: "menu", image: UIImage(systemName: "ellipsis"), primaryAction: nil, menu: UIMenu(children: [shareButton, downloadButton]))
			items = [self.collectionView.editButtonItem, dotdotdotButton]
		}
		self.navigationItem.setRightBarButtonItems(items, animated: true)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		guard let updatedPack = hoarder.emojiPacks.first(where: { $0.id == pack.id }) else { return }
		self.pack = updatedPack
		self.navigationItem.title = pack.name
		collectionView.refreshUI(with: pack.items)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		hoarder.updateEmojiPack(pack)
	}
}
