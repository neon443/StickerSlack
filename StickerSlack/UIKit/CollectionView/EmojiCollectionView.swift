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
	
	func makeUIView(context: Context) -> UICollectionView {
		let collectionView = context.coordinator as UICollectionViewController
		collectionView.collectionView.register(PlainEmojiCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
		collectionView.collectionView.dataSource = context.coordinator
		return collectionView.collectionView
	}
	
	func updateUIView(_ uiView: UICollectionView, context: Context) {
		context.coordinator.hoarder = hoarder
		context.coordinator.pack = pack
		uiView.reloadData()
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(hoarder: hoarder, pack: pack, width: width, spacing: spacing)
	}
	
	final class Coordinator: UICollectionViewController {
		var hoarder: EmojiHoarder
		var pack: EmojiPack
		var width: CGFloat
		var spacing: CGFloat
		var layout = UICollectionViewFlowLayout()
		
		init(hoarder: EmojiHoarder, pack: EmojiPack, width: CGFloat, spacing: CGFloat) {
			self.hoarder = hoarder
			self.pack = pack
			self.width = width
			self.spacing = spacing
			
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
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PlainEmojiCollectionViewCell
				
			guard !hoarder.trie.dict.isEmpty else { return cell }
			
			let emojiName = pack.items[indexPath.item]
			
			guard let emoji = hoarder.trie.dict[emojiName] else { return cell }
			
			cell.configure(with: hoarder, emoji: emoji)
			return cell
		}
	}
}

