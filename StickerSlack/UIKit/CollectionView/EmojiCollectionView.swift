//
//  EmojiCollectionView.swift
//  StickerSlack
//
//  Created by neon443 on 24/04/2026.
//

import Foundation
import UIKit
import SwiftUI
import Haptics

struct EmojiCollectionView: UIViewRepresentable {
	let hoarder: EmojiHoarder
	let items: [String]
	let pack: EmojiPack?
	let width: CGFloat
	let spacing: CGFloat = 16
	let style: EmojiCollectionView.Style
	
	func makeUIView(context: Context) -> UICollectionView {
		let collectionView = context.coordinator as UICollectionViewController
		collectionView.collectionView.register(PlainEmojiCollectionViewCell.self, forCellWithReuseIdentifier: "plain")
		collectionView.collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "full")
		collectionView.collectionView.dataSource = context.coordinator
		collectionView.collectionView.delegate = context.coordinator
		return collectionView.collectionView
	}
	
	func updateUIView(_ uiView: UICollectionView, context: Context) {
		context.coordinator.hoarder = hoarder
		context.coordinator.items = items
		context.coordinator.pack = pack
		uiView.reloadData()
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(
			hoarder: hoarder,
			items: items,
			pack: pack,
			width: width,
			spacing: spacing,
			style: style
		)
	}
	
	enum Style {
		case plain
		case plainWithMenu
		case full
	}
	
	final class Coordinator: UICollectionViewController, UICollectionViewDelegateFlowLayout {
		var hoarder: EmojiHoarder
		var items: [String]
		var pack: EmojiPack?
		var width: CGFloat
		var spacing: CGFloat
		var style: EmojiCollectionView.Style
		
		var layout = UICollectionViewFlowLayout()
		
		init(
			hoarder: EmojiHoarder,
			items: [String],
			pack: EmojiPack?,
			width: CGFloat,
			spacing: CGFloat,
			style: EmojiCollectionView.Style
		) {
			self.hoarder = hoarder
			self.items = items
			if let pack {
				self.pack = pack
				self.items = pack.items
			}
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
			return items.count
		}
		
		override func collectionView(
			_ collectionView: UICollectionView,
			cellForItemAt indexPath: IndexPath
		) -> UICollectionViewCell {
			let cell: PlainEmojiCollectionViewCell
			switch style {
			case .plain, .plainWithMenu:
				cell = collectionView.dequeueReusableCell(withReuseIdentifier: "plain", for: indexPath) as! PlainEmojiCollectionViewCell
			case .full:
				cell = collectionView.dequeueReusableCell(withReuseIdentifier: "full", for: indexPath) as! EmojiCollectionViewCell
			}
			
			guard !hoarder.trie.dict.isEmpty else { return cell }
			let emojiName = items[indexPath.item]
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
			
			guard self.style == .full else { return defaultSize }
			guard !hoarder.trie.dict.isEmpty else { return defaultSize }
			let emojiName = items[indexPath.item]
			
			let label = UILabel()
			label.font = .preferredFont(forTextStyle: .caption1)
			label.numberOfLines = 0
			label.text = emojiName
			let labelHeight = label.sizeThatFits(CGSize(width: width, height: .infinity)).height
			
			print(width+labelHeight+4)
			
			return CGSize(width: width, height: width+labelHeight+4)
		}
		
		override func collectionView(
			_ collectionView: UICollectionView,
			contextMenuConfigurationForItemAt indexPath: IndexPath,
			point: CGPoint
		) -> UIContextMenuConfiguration? {
			guard self.style == .plainWithMenu else { return nil }
			return UIContextMenuConfiguration(
				identifier: nil,
				previewProvider: nil) { suggestedActions in
					let emojiName = self.items[indexPath.row]
					let copyName = UIAction(title: "Copy Name", image: UIImage(systemName: "doc.on.clipboard")) { action in
						UIPasteboard.general.string = emojiName
						Haptic.success.trigger()
					}
					let copyImage = UIAction(title: "Copy Image", image: UIImage(systemName: "photo.fill.on.rectangle.fill")) { action in
						UIPasteboard.general.image = self.hoarder.trie.dict[emojiName]?.image
						Haptic.success.trigger()
					}
					let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { action in
						
					}
					let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { action in
						Task.detached {
							await self.hoarder.delete(emoji: self.hoarder.trie.dict[emojiName])
						}
					}
					delete.attributes.update(with: .destructive)
					return UIMenu(title: emojiName, children: [copyName, copyImage, share, delete])
				}
		}
	}
}

