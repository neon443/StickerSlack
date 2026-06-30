//
//  EmojiCollectionView.swift
//  StickerSlack
//
//  Created by neon443 on 24/04/2026.
//

import Foundation
import UIKit
import Haptics

final class EmojiCollectionView: UICollectionViewController, UICollectionViewDelegateFlowLayout {
	var hoarder: EmojiHoarder
	var items: [String]
	var width: CGFloat
	var style: EmojiCollectionView.Style
	var edit: Bool? = false
	var onRemove: ((String) -> Void)?
	var onTap: ((String) -> Void)?
	
	var dataSource: UICollectionViewDiffableDataSource<Int, String>!
	
	// [width: [label: height]]
	static var labelSizeDict: [CGFloat: [String: CGFloat]] = [:]
	
	let initDate = Date.now
	var layout = UICollectionViewFlowLayout()
	var displayLink: CADisplayLink!
	
	init(
		hoarder: EmojiHoarder,
		items: [String],
		width: CGFloat,
		style: EmojiCollectionView.Style,
	) {
		self.hoarder = hoarder
		self.items = items
		self.width = width
		self.style = style
		
		super.init(collectionViewLayout: layout)
		
		self.dataSource = UICollectionViewDiffableDataSource<Int, String>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: String) -> UICollectionViewCell? in
			self.collectionView(collectionView, cellForItemAt: indexPath)
		}
		collectionView.dataSource = dataSource
		
		if self.style == .jumboMoji {
			self.layout.minimumInteritemSpacing = 0
			self.layout.minimumLineSpacing = 0
			collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		} else {
			self.layout.minimumInteritemSpacing = 8
			collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
		}
		layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
		
		refreshUI(edit: false, with: items)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	enum Style {
		case plain
		case plainWithLabel
		case plainWithMenu
		case full
		case jumboMoji
	}
	
	override func viewWillLayoutSubviews() {
		self.refreshUI(edit: edit, with: items)
	}
	
	func refreshUI(edit: Bool?, with items: [String]) {
		self.edit = edit
		if edit ?? false {
			self.startAnimating()
		} else {
			self.stopAnimating()
		}
		
		for cell in collectionView.visibleCells {
			if let cell = cell as? EmojiCollectionViewCell {
				cell.setEdit(to: edit)
			}
		}
		
		let itemsBefore = self.items
		let itemsAfter = items
		self.items = items
		Task.detached {
			//if its being cleared or adding 10k+
			guard !itemsAfter.isEmpty && itemsAfter.count-itemsBefore.count < 10_000 else {
				await self.instantApplySnapshot()
				return
			}
			await self.applySnapshot(animated: true)
		}
	}
	
	func makeSnapshot() -> NSDiffableDataSourceSnapshot<Int, String> {
		var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
		snapshot.appendSections([0])
		snapshot.appendItems(items, toSection: 0)
		return snapshot
	}
	func applySnapshot(animated: Bool) async {
		let snapshot = makeSnapshot()
		await (self.collectionView.dataSource as! UICollectionViewDiffableDataSource).apply(snapshot, animatingDifferences: animated)
	}
	func instantApplySnapshot() async {
		let snapshot = makeSnapshot()
		await (self.collectionView.dataSource as! UICollectionViewDiffableDataSource).applySnapshotUsingReloadData(snapshot)
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return items.count
	}
	
	override func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		let cell: PlainEmojiCollectionViewCell
		guard !hoarder.trie.dict.isEmpty else { return UICollectionViewCell() }
		let emojiName = items[indexPath.item]
		
		switch style {
		case .plain, .plainWithMenu, .jumboMoji:
			cell = collectionView.dequeueReusableCell(withReuseIdentifier: "plain", for: indexPath) as! PlainEmojiCollectionViewCell
		case .full, .plainWithLabel:
			cell = collectionView.dequeueReusableCell(withReuseIdentifier: "full", for: indexPath) as! EmojiCollectionViewCell
			(cell as! EmojiCollectionViewCell).setEdit(to: edit)
			(cell as! EmojiCollectionViewCell).onRemove = {
				guard let index = self.items.firstIndex(of: $0) else { return }
				self.items.remove(at: index)
				Task.detached {
					await self.applySnapshot(animated: true)
				}
				self.onRemove?($0)
			}
		}
		guard let emoji = hoarder.trie.dict[emojiName] else { return cell }
		cell.width = width
		cell.style = style
		cell.onTap = { self.onTap?(emojiName) }
		cell.configure(with: hoarder, emoji: emoji)
		return cell
	}
	
	func startAnimating() {
		displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
		displayLink.add(to: .main, forMode: .common)
	}
	func stopAnimating() {
		displayLink?.remove(from: .main, forMode: .common)
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
	
	override func collectionView(
		_ collectionView: UICollectionView,
		contextMenuConfigurationForItemAt indexPath: IndexPath,
		point: CGPoint
	) -> UIContextMenuConfiguration? {
		guard self.style == .plainWithMenu else { return nil }
		
		var menuChildrem: [UIMenuElement] = []
		let emojiName = self.items[indexPath.row]
		
		let packMenuItem: (EmojiHoarder, Int) -> UIAction = { hoarder, packIndex in
			let pack = hoarder.emojiPacks[packIndex]
			return UIAction(
				title: pack.name,
				subtitle: "\(pack.items.count) item\(pack.items.count.plural)",
				image: pack.items.contains(emojiName) ? UIImage(systemName: "checkmark") : nil
			) { action in
				hoarder.emojiPacks[packIndex].addRemove(emojiName)
				hoarder.saveEmojiPacks()
			}
		}
		var packMenuItems: [UIMenuElement] = []
		for i in self.hoarder.emojiPacks.indices {
			packMenuItems.append(packMenuItem(self.hoarder, i))
		}
		let createNewPackMenu = UIMenu(
			options: .displayInline,
			children: [
				UIAction(title: "Create New", image: UIImage(systemName: "plus")) { action in
					self.hoarder.newEmojiPack(withItems: [emojiName])
				}
			]
		)
		packMenuItems.append(createNewPackMenu)
		menuChildrem.append(UIMenu(title: "Add to Pack", image: UIImage(systemName: "square.stack.3d.up.fill"), children: packMenuItems))
		
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
		menuChildrem.append(UIMenu(options: .displayInline, children: [copyName, copyImage, share]))
		
		let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { action in
			Task.detached {
				await self.hoarder.delete(emoji: self.hoarder.trie.dict[emojiName])
			}
			self.items.remove(at: indexPath.row)
			Task.detached {
				await self.applySnapshot(animated: true)
			}
		}
		delete.attributes.update(with: .destructive)
		menuChildrem.append(UIMenu(options: .displayInline, children: [delete]))
		
		let menu = UIMenu(title: emojiName, children: menuChildrem)
		return UIContextMenuConfiguration(
			identifier: nil,
			previewProvider: nil) { suggestedActions in
				return menu
			}
	}
}
