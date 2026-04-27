//
//  EmojiCollectionView.swift
//  StickerSlack
//
//  Created by neon443 on 24/04/2026.
//

import Foundation
import UIKit
import SwiftUI

struct EmojiCollectionView: UIViewRepresentable {
	let hoarder: EmojiHoarder
	let pack: EmojiPack
	let width: CGFloat
	let spacing: CGFloat = 16
	let style: EmojiCollectionView.Style
	
	func makeUIView(context: Context) -> UICollectionView {
		let collectionView = context.coordinator as UICollectionViewController
		collectionView.collectionView.register(PlainEmojiCollectionViewCell.self, forCellWithReuseIdentifier: "plainCell")
		collectionView.collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
		collectionView.collectionView.dataSource = context.coordinator
		collectionView.collectionView.delegate = context.coordinator
		return collectionView.collectionView
	}
	
	func updateUIView(_ uiView: UICollectionView, context: Context) {
		context.coordinator.hoarder = hoarder
		context.coordinator.pack = pack
		uiView.reloadData()
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(
			hoarder: hoarder,
			pack: pack,
			width: width,
			spacing: spacing,
			style: style
		)
	}
	
	enum Style {
		case plain
		case full
	}
	
	final class Coordinator: UICollectionViewController, UICollectionViewDelegateFlowLayout {
		var hoarder: EmojiHoarder
		var pack: EmojiPack
		var width: CGFloat
		var spacing: CGFloat
		var style: EmojiCollectionView.Style
		
		var layout = UICollectionViewFlowLayout()
		
		init(
			hoarder: EmojiHoarder,
			pack: EmojiPack,
			width: CGFloat,
			spacing: CGFloat,
			style: EmojiCollectionView.Style
		) {
			self.hoarder = hoarder
			self.pack = pack
			self.width = width
			self.spacing = spacing
			self.style = style
			
			layout.sectionInset.left = 16
			layout.sectionInset.right = 16
			
			layout.itemSize = CGSize(width: width, height: width)
			
			super.init(collectionViewLayout: layout)
		}
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		override func viewDidLayoutSubviews() {
			layout.sectionInset.left = 16
			layout.sectionInset.right = 16
			
			layout.itemSize = CGSize(width: width, height: width)
		}
		
		override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
			return pack.items.count
		}
		
		override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
			let cell: PlainEmojiCollectionViewCell
			switch style {
			case .plain:
				cell = collectionView.dequeueReusableCell(withReuseIdentifier: "plainCell", for: indexPath) as! PlainEmojiCollectionViewCell
			case .full:
				cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! EmojiCollectionViewCell
			}
			
			guard !hoarder.trie.dict.isEmpty else { return cell }
			let emojiName = pack.items[indexPath.item]
			guard let emoji = hoarder.trie.dict[emojiName] else { return cell }
			
			cell.configure(with: hoarder, emoji: emoji)
			return cell
		}
		
		func collectionView(
			_ collectionView: UICollectionView,
			layout collectionViewLayout: UICollectionViewLayout,
			sizeForItemAt indexPath: IndexPath
		) -> CGSize {
			let defaultSize = CGSize(width: width, height: width)
			
			guard !hoarder.trie.dict.isEmpty else { return defaultSize }
			let emojiName = pack.items[indexPath.item]
			
			let label = UILabel()
			label.font = .preferredFont(forTextStyle: .caption1)
			label.numberOfLines = 0
			label.text = emojiName
			let labelHeight = label.sizeThatFits(CGSize(width: width, height: .infinity)).height
			
			print(width+labelHeight)
			
			return CGSize(width: width, height: width+labelHeight)
		}
	}
}

