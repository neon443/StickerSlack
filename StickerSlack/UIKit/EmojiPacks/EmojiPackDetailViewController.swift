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
	
	let emptyCollectionView: UIViewController
	
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
		
		let suiView = EmptyCollectionView(
			title: "No Emoji",
			details: "Add emojis to this pack by editing it using the edit button in the toolbar.",
			systemImage: "exclamationmark.triangle.fill"
		)
		self.emptyCollectionView = UIHostingController(rootView: suiView)
		
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
			self.refreshUI()
		}
		
		collectionView.addChild(emptyCollectionView)
		self.view.addSubview(emptyCollectionView.view)
		emptyCollectionView.view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			emptyCollectionView.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			emptyCollectionView.view.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
			emptyCollectionView.view.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
		])
		emptyCollectionView.didMove(toParent: collectionView)
		checkForEmptyPack()
		
		self.searchView.setOnTapCallback { selection in
			guard !self.pack.items.contains(selection) else {
				Haptic.error.trigger()
				return
			}
			Haptic.heavy.trigger()
			self.pack.items.append(selection)
			self.collectionView.items = pack.items
			self.refreshUI()
		}
		
		self.adderSheetButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(showSheet))
		
		let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(hideSheet))
		searchView.resultsView.navigationItem.rightBarButtonItem = doneButton
		
		self.shareButton = UIAction(title: "Share...", image: UIImage(systemName: "square.and.arrow.up")) { action in
			self.share()
		}
		self.downloadButton = UIAction(title: "", image: UIImage(systemName: "")) { action in
			self.downloadButtonAction()
		}
		updateDownloadButton()
		self.navigationItem.title = pack.name
		self.setToolbar(editing: false)
		
		collectionView.onEditChange = { self.setToolbar(editing: $0) }
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func checkForEmptyPack() {
		self.emptyCollectionView.view.isHidden = !self.pack.items.isEmpty
		
		if self.pack.items.isEmpty {
			
		} else {
			
		}
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
			} else {
				await pack.downloadAll(hoarder: hoarder)
			}
			self.setToolbar(editing: false)
			refreshUI()
		}
	}
	
	func updateDownloadButton() {
		if pack.allDownloaded(in: hoarder) {
			self.downloadButton.image = UIImage(systemName: "trash")
			self.downloadButton.title = "Remove Download"
		} else {
			self.downloadButton.image = UIImage(systemName: "arrow.down")
			self.downloadButton.title = "Download"
		}
	}
	
	@objc func share() {
		let itemProvider = NSItemProvider(item: pack.shareLink() as NSURL, typeIdentifier: UTType.url.identifier)
		let config = UIActivityItemsConfiguration(itemProviders: [itemProvider])
		let shareSheet = UIActivityViewController(activityItemsConfiguration: config)
		present(shareSheet, animated: true)
	}
	
	func setToolbar(editing: Bool) {
		var items: [UIBarButtonItem] = [self.collectionView.editButtonItem]
		if editing {
			if #available(iOS 26, *) {
				items.append(.fixedSpace(0))
			}
			items.append(self.adderSheetButton)
		} else {
			let shareMenu = UIMenu(options: .displayInline, children: [shareButton])
			let menu = UIMenu(children: [downloadButton, shareMenu])
			let dotdotdotButton = UIBarButtonItem(
				title: "menu",
				image: UIImage(systemName: "ellipsis"),
				primaryAction: nil,
				menu: menu
			)
			items = [self.collectionView.editButtonItem, dotdotdotButton]
		}
		self.navigationItem.setRightBarButtonItems(items, animated: true)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		guard let updatedPack = hoarder.emojiPacks.first(where: { $0.id == pack.id }) else { return }
		self.pack = updatedPack
		refreshUI()
	}
	
	func refreshUI() {
		self.navigationItem.title = pack.name
//		self.navigationItem.documentProperties
		checkForEmptyPack()
		updateDownloadButton()
		setToolbar(editing: isEditing)
		collectionView.refreshUI(with: pack.items)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		hoarder.updateEmojiPack(pack)
	}
}
