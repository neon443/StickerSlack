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
	
	var effectView: UIVisualEffectView!
	var countLabel: UILabel!
	var adderSheetButton: UIBarButtonItem!
	var downloadButton: UIAction!
	var renameButton: UIAction!
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
			self.hoarder.updateEmojiPack(self.pack)
		}
		collectionView.onInternalMove = {
			self.pack.items = self.collectionView.items
			self.refreshUI()
			self.hoarder.updateEmojiPack(self.pack)
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
		
		self.countLabel = UILabel()
		countLabel.text = "hello default"
		countLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
		countLabel.textAlignment = .center
		self.effectView = UIVisualEffectView(effect: nil)
		self.view.addSubview(effectView)
		var effect: UIVisualEffect
		if #available(iOS 19, *) {
			let glassEffect = UIGlassEffect()
			glassEffect.isInteractive = true
			effect = glassEffect
		} else {
			effect = UIBlurEffect(style: .systemThinMaterial)
		}
		effectView.effect = effect
		effectView.layer.masksToBounds = true
		effectView.clipsToBounds = true
		effectView.contentView.addSubview(countLabel)
		effectView.translatesAutoresizingMaskIntoConstraints = false
		countLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			effectView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			effectView.heightAnchor.constraint(equalTo: countLabel.heightAnchor, constant: 12),
			effectView.widthAnchor.constraint(equalTo: countLabel.widthAnchor, constant: 24),
			effectView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
			
			countLabel.centerXAnchor.constraint(equalTo: effectView.centerXAnchor),
			countLabel.centerYAnchor.constraint(equalTo: effectView.centerYAnchor)
		])
		
		self.adderSheetButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(showSheet))
		
		let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(hideSheet))
		searchView.resultsView.navigationItem.rightBarButtonItem = doneButton
		
		self.shareButton = UIAction(title: "Share...", image: UIImage(systemName: "square.and.arrow.up")) { action in
			self.share()
		}
		self.renameButton = UIAction(title: "Rename", image: UIImage(systemName: "pencil")!, handler: { action in
			self.renamePack()
		})
		self.downloadButton = UIAction(title: "", image: UIImage(systemName: "")) { action in
			self.downloadButtonAction()
		}
		updateDownloadButton()
		self.navigationItem.title = pack.name
		self.setToolbar()
		
		collectionView.onEditChange = { self.setToolbar() }
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func refreshUI() {
		self.navigationItem.title = pack.name
		self.countLabel.text = pack.description
//		self.navigationItem.documentProperties
		checkForEmptyPack()
		updateDownloadButton()
		setToolbar()
		collectionView.refreshUI(with: pack.items)
	}
	
	func renamePack() {
		let alert = UIAlertController(title: "Rename", message: "", preferredStyle: .alert)
		alert.addTextField { textField in
			textField.text = self.pack.name
			textField.placeholder = self.pack.name
		}
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
			self.dismiss(animated: true)
		}))
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
			guard let textField = alert.textFields?.first,
				  let text = textField.text else { return }
			self.pack.name = text
			self.hoarder.updateEmojiPack(self.pack)
			self.refreshUI()
			self.dismiss(animated: true)
		}))
		alert.preferredAction = alert.actions.last
		self.present(alert, animated: true)
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
			self.setToolbar()
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
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		collectionView.edit(editing, animated: animated)
	}
	
	func setToolbar() {
		var items: [UIBarButtonItem] = [self.editButtonItem]
		if self.isEditing {
			if #available(iOS 26, *) {
				items.append(.fixedSpace(0))
			}
			items.append(self.adderSheetButton)
		} else {
			let shareMenu = UIMenu(options: .displayInline, children: [shareButton])
			let menu = UIMenu(children: [downloadButton, renameButton, shareMenu])
			let dotdotdotButton = UIBarButtonItem(
				title: "menu",
				image: UIImage(systemName: "ellipsis"),
				primaryAction: nil,
				menu: menu
			)
			items = [self.editButtonItem, dotdotdotButton]
		}
		self.navigationItem.setRightBarButtonItems(items, animated: true)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		guard let updatedPack = hoarder.emojiPacks.first(where: { $0.id == pack.id }) else { return }
		self.pack = updatedPack
		refreshUI()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		effectView.layer.cornerRadius = effectView.bounds.height/2
		collectionView.collectionView.contentInset.bottom = 8 + effectView.frame.height
	}
	
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		hoarder.updateEmojiPack(pack)
	}
}
