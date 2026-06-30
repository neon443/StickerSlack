//
//  EmojiCollectionViewRepresentable.swift
//  StickerSlack
//
//  Created by neon443 on 30/06/2026.
//

import Foundation
import UIKit
import SwiftUI
import Haptics

struct EmojiCollectionViewRepresentable: UIViewRepresentable {
	let hoarder: EmojiHoarder
	let items: [String]
	let width: CGFloat
	let style: EmojiCollectionView.Style
	var edit: Bool?
	var onRemoveSUI: ((String) -> Void)?
	var onTapCallback: ((String) -> Void)?
	
	func makeUIView(context: Context) -> UICollectionView {
		let collectionView = context.coordinator as UICollectionViewController
		collectionView.collectionView.register(PlainEmojiCollectionViewCell.self, forCellWithReuseIdentifier: "plain")
		collectionView.collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "full")
		collectionView.collectionView.delegate = context.coordinator
		return collectionView.collectionView
	}
	
	func updateUIView(_ uiView: UICollectionView, context: Context) {
		context.coordinator.hoarder = hoarder
		context.coordinator.items = items
		context.coordinator.edit = edit
		context.coordinator.onRemove = onRemoveSUI
		context.coordinator.onTap = onTapCallback
		uiView.setNeedsLayout()
		context.coordinator.refreshUI(edit: edit, with: items)
	}
	
	func makeCoordinator() -> EmojiCollectionView {
		EmojiCollectionView(
			hoarder: hoarder,
			items: items,
			width: width,
			style: style
		)
	}
}
