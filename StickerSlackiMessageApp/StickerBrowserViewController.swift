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
	var labelStack: UIVisualEffectView
	var labelTitle: UILabel
	var labelSubTitle: UILabel
	var emptyView: UIViewController
	
	init(emojiHoarder: EmojiHoarder, pack: EmojiPack?) {
		self.emojiHoarder = emojiHoarder
		self.pack = pack
		
		self.labelTitle = UILabel()
		self.labelSubTitle = UILabel()
		self.labelStack = UIVisualEffectView(effect: nil)
		var effect: UIVisualEffect
		if #available(iOS 19, *) {
			let glassEffect = UIGlassEffect()
			glassEffect.isInteractive = true
			effect = glassEffect
		} else {
			effect = UIBlurEffect(style: .systemThinMaterial)
		}
		labelStack.effect = effect
		
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
		
		let stack = UIStackView(arrangedSubviews: [labelTitle, labelSubTitle])
		labelStack.contentView.addSubview(stack)
		self.view.addSubview(labelStack)
		stack.translatesAutoresizingMaskIntoConstraints = false
		labelStack.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			stack.heightAnchor.constraint(equalTo: labelStack.heightAnchor),
			stack.widthAnchor.constraint(equalTo: labelStack.widthAnchor),
			
			labelStack.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			labelStack.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -4)
		])
		stack.axis = .vertical
		stack.insetsLayoutMarginsFromSafeArea = false
		stack.layoutMargins = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
		stack.isLayoutMarginsRelativeArrangement = true
		
		labelStack.layer.masksToBounds = true
		
		labelTitle.textColor = .white
		labelTitle.font = UIFont.preferredFont(forTextStyle: .subheadline)
		labelTitle.textAlignment = .center
		
		labelSubTitle.textColor = .white
		labelSubTitle.font = UIFont.preferredFont(forTextStyle: .caption1)
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
		UIView.transition(with: labelStack, duration: 0.25, options: [.transitionCrossDissolve, .allowUserInteraction]) {
			self.labelTitle.text = self.pack?.name ?? "All Downloaded"
			self.labelSubTitle.text = self.pack?.downloadedDescription(self.emojiHoarder) ??
			"\(self.emojiHoarder.downloadedStickers.count) emoji\(self.emojiHoarder.downloadedStickers.count.plural)"

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
