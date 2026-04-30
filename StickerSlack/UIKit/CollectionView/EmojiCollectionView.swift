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
	let style: EmojiCollectionView.Style
	var edit: Bool?
	var onRemoveSUI: ((String) -> Void)?
	
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
		context.coordinator.onRemove = onRemoveSUI
		
		context.coordinator.edit = edit
		if edit ?? false {
			context.coordinator.startAnimating()
		} else {
			context.coordinator.stopAnimating()
		}
		
		for cell in uiView.visibleCells {
			if let cell = cell as? EmojiCollectionViewCell {
				cell.setEdit(to: edit)
			}
		}
		
		if items != context.coordinator.items || context.coordinator.pack != pack {
			context.coordinator.items = items
			context.coordinator.pack = pack
			uiView.reloadData()
		}
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(
			hoarder: hoarder,
			items: items,
			pack: pack,
			width: width,
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
		var style: EmojiCollectionView.Style
		var edit: Bool? = false
		var onRemove: ((String) -> Void)?
		
		var labelHeightDict: [String: CGFloat] = [:]
		
		let initDate = Date.now
		var layout = UICollectionViewFlowLayout()
		var displayLink: CADisplayLink!
		
		init(
			hoarder: EmojiHoarder,
			items: [String],
			pack: EmojiPack?,
			width: CGFloat,
			style: EmojiCollectionView.Style,
		) {
			self.hoarder = hoarder
			self.items = items
			if let pack {
				self.pack = pack
				self.items = pack.items
			}
			self.width = width
			self.style = style
			
			layout.minimumInteritemSpacing = 8
			
			super.init(collectionViewLayout: layout)
			collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
		}
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
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
				(cell as! EmojiCollectionViewCell).setEdit(to: edit)
				(cell as! EmojiCollectionViewCell).onRemove = {
					guard let index = self.items.firstIndex(of: $0) else { return }
					self.items.remove(at: index)
					collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
					self.onRemove?($0)
				}
			}
			
			guard !hoarder.trie.dict.isEmpty else { return cell }
			let emojiName = items[indexPath.item]
			guard let emoji = hoarder.trie.dict[emojiName] else { return cell }
			
			cell.configure(with: hoarder, emoji: emoji)
			return cell
		}
		
		func startAnimating() {
			displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
			displayLink.add(to: .main, forMode: .common)
		}
		func stopAnimating() {
			displayLink?.invalidate()
			UIView.animate(withDuration: 0.2) {
				for cell in self.collectionView.visibleCells {
					cell.transform = CGAffineTransform.identity
				}
			}
		}
		@objc
		func updateAnimation() {
			let t = Date().timeIntervalSince(initDate)
			let angle = ((sin(t*20)*4)/360)*2*CGFloat.pi
			
			for cell in collectionView.visibleCells {
				cell.transform = CGAffineTransform(rotationAngle: angle)
			}
		}
		
		func collectionView(
			_ collectionView: UICollectionView,
			layout collectionViewLayout: UICollectionViewLayout,
			sizeForItemAt indexPath: IndexPath
		) -> CGSize {
			let totalWidth = collectionView.bounds.width
			let availWidth = totalWidth-(collectionView.contentInset.left*2)
			let cols = max(1, floor(availWidth/width))
			let totalSpacing = layout.minimumInteritemSpacing * (cols - 1)
			let itemWidth = (availWidth-totalSpacing)/cols
			let defaultSize = CGSize(width: itemWidth, height: itemWidth)
			
			guard self.style == .full else { return defaultSize }
			guard !hoarder.trie.dict.isEmpty else { return defaultSize }
			let emojiName = items[indexPath.item]
			
			let labelHeight: CGFloat
			if let storedHeight = labelHeightDict[emojiName] {
				labelHeight = storedHeight
			} else {
				let label = UILabel()
				label.font = .preferredFont(forTextStyle: .caption1)
				label.numberOfLines = 0
				label.text = emojiName
				labelHeight = label.sizeThatFits(CGSize(width: itemWidth, height: .infinity)).height
				labelHeightDict[emojiName] = labelHeight
			}
			
			return CGSize(width: itemWidth, height: itemWidth+labelHeight+4)
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
						self.items.remove(at: indexPath.row)
						collectionView.performBatchUpdates {
							collectionView.deleteItems(at: [indexPath])
						}
					}
					delete.attributes.update(with: .destructive)
					return UIMenu(title: emojiName, children: [copyName, copyImage, share, delete])
				}
		}
	}
}
