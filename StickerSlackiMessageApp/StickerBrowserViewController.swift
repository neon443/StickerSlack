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
	var labelStack: UIStackView
	var labelTitle: UILabel
	var labelSubTitle: UILabel
	var emptyView: UIViewController
	
	init(emojiHoarder: EmojiHoarder, pack: EmojiPack?) {
		self.emojiHoarder = emojiHoarder
		self.pack = pack
		
		self.labelTitle = UILabel()
		self.labelSubTitle = UILabel()
		self.labelStack = UIStackView(arrangedSubviews: [labelTitle, labelSubTitle])
		
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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.addSubview(labelStack)
		labelStack.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			labelStack.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			labelStack.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
		])
		labelStack.axis = .vertical
		labelStack.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).inverted.withAlphaComponent(0.75)
		labelStack.insetsLayoutMarginsFromSafeArea = false
		labelStack.layoutMargins = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
		labelStack.isLayoutMarginsRelativeArrangement = true
		
		labelStack.layer.cornerCurve = .continuous
		labelStack.layer.maskedCorners = [
			.layerMinXMinYCorner,
			.layerMaxXMinYCorner
		]
		labelStack.layer.masksToBounds = true
		
		labelTitle.font = UIFont.systemFont(ofSize: 14)
		labelTitle.textAlignment = .center
		
		labelSubTitle.font = UIFont.systemFont(ofSize: 12)
		labelSubTitle.textAlignment = .center
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		setScrollbars()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		labelStack.layer.cornerRadius = labelStack.frame.height/4
	}
	
	@objc func reload() {
		UIView.transition(with: labelStack, duration: 0.25, options: .transitionCrossDissolve) {
			self.labelTitle.text = self.pack?.name ?? "All Downloaded"
			self.labelSubTitle.text = self.pack?.downloadedDescription(self.emojiHoarder) ?? "idk"

			self.view.layoutIfNeeded()
		}
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
		setEmptyViewTo(visible: msStickers.isEmpty)
		stickerBrowserView.reloadData()
		guard let subview = stickerBrowserView.subviews.first,
			  let collectionView = subview as? UICollectionView else { return }
		collectionView.setContentOffset(.zero, animated: true)
		DispatchQueue.main.async {
			self.setScrollbars()
		}
	}
	
	func setScrollbars() {
		guard let subview = stickerBrowserView.subviews.first,
			  let collectionView = subview as? UICollectionView else { return }
		collectionView.automaticallyAdjustsScrollIndicatorInsets = false
		collectionView.directionalLayoutMargins.trailing = 0
		self.view.directionalLayoutMargins.trailing = 0
		collectionView.verticalScrollIndicatorInsets.bottom = view.safeAreaInsets.bottom
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
