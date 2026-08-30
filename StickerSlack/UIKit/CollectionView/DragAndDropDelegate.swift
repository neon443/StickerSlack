//
//  DragAndDropDelegate.swift
//  StickerSlack
//
//  Created by neon443 on 30/08/2026.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

extension EmojiCollectionView: UICollectionViewDragDelegate {
	func collectionView(
		_ collectionView: UICollectionView,
		itemsForBeginning session: any UIDragSession,
		at indexPath: IndexPath
	) -> [UIDragItem] {
		let emojiName = items[indexPath.row]
		guard let emoji = hoarder.trie.dict[emojiName] else { return [] }
		
		let item = NSItemProvider(item: emojiName as NSSecureCoding, typeIdentifier: UTType.utf8PlainText.identifier)
		
		let dragItem = UIDragItem(itemProvider: item)
		
		return [dragItem]
	}
}

extension EmojiCollectionView: UICollectionViewDropDelegate {
	func collectionView(_ collectionView: UICollectionView, canHandle session: any UIDropSession) -> Bool {
		return true
	}
	
	func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: any UICollectionViewDropCoordinator) {
		guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
		
		coordinator.items.forEach { dropItem in
			guard let sourceIndexPath = dropItem.sourceIndexPath else { return }
			
			collectionView.performBatchUpdates({
				moveItem(from: sourceIndexPath, to: destinationIndexPath)
				refreshUI(with: items)
			}, completion: { _ in
				coordinator.drop(dropItem.dragItem, toItemAt: destinationIndexPath)
			})
		}
		
		onInternalMove?()
	}
	
	func moveItem(from: IndexPath, to: IndexPath) {
		let removed = self.items.remove(at: from.row)
		self.items.insert(removed, at: to.row)
	}
	
	func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: any UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
		return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
	}
}
