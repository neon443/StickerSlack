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
	let items: [String]
	let spacing: Int = 0
	let columns: Int?
	
	func makeUIView(context: Context) -> UICollectionView {
		let collectionView = context.coordinator as UICollectionViewController
		collectionView.collectionView.register(PlainEmojiCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
		collectionView.collectionView.dataSource = context.coordinator
		return collectionView.collectionView
	}
	
	func updateUIView(_ uiView: UICollectionView, context: Context) {
		context.coordinator.hoarder = hoarder
		context.coordinator.items = items
		uiView.reloadData()
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(hoarder: hoarder, items: items, columns: 6)
	}
	
	final class Coordinator: UICollectionViewController {
		var hoarder: EmojiHoarder
		var items: [String]
		var columns: Int?
		var layout = UICollectionViewFlowLayout()
		
		init(hoarder: EmojiHoarder, items: [String], columns: Int?) {
			self.hoarder = hoarder
			self.items = items
			self.columns = columns
			
			if columns != nil {
				layout.itemSize = CGSize(
					width: UIScreen.main.bounds.width/CGFloat(columns!),
					height: UIScreen.main.bounds.width/CGFloat(columns!)
				)
			}
			
			super.init(collectionViewLayout: layout)
		}
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
			return items.count
		}
		
		override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PlainEmojiCollectionViewCell
				
			guard !hoarder.trie.dict.isEmpty else { return cell }
			
			let emojiName = items[indexPath.item]
			
			guard let emoji = hoarder.trie.dict[emojiName] else { return cell }
			
			cell.configure(with: hoarder, emoji: emoji)
			return cell
		}
	}
}

