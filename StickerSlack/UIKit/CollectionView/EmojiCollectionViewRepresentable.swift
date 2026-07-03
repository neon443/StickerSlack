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
		return collectionView.collectionView
	}
	
	func updateUIView(_ uiView: UICollectionView, context: Context) {
		context.coordinator.hoarder = hoarder
		context.coordinator.items = items
		context.coordinator.onRemove = onRemoveSUI
		context.coordinator.onTap = onTapCallback
		context.coordinator.setEditing(edit ?? false, animated: true)
		uiView.setNeedsLayout()
		context.coordinator.refreshUI(with: items)
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
