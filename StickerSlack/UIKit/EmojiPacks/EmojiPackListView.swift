//
//  EmojiPackListView.swift
//  StickerSlack
//
//  Created by neon443 on 05/07/2026.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

class EmojiPackListView: UITableViewController {
	var emojiHoarder: EmojiHoarder
	var multiDeleteButton: UIBarButtonItem!
	
	init(emojiHoarder: EmojiHoarder) {
		self.emojiHoarder = emojiHoarder
		super.init(style: .insetGrouped)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		self.tableView.allowsMultipleSelectionDuringEditing = true
		self.navigationItem.title = "Packs"
		
		self.multiDeleteButton = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(multiDelete))
		self.setToolbarItems([multiDeleteButton], animated: true)
		
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(
			image: UIImage(systemName: "plus"),
			style: .plain,
			target: self,
			action: #selector(addPack)
		)
		self.navigationItem.rightBarButtonItem = self.editButtonItem
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return emojiHoarder.emojiPacks.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		var content = cell.defaultContentConfiguration()
		guard emojiHoarder.emojiPacks.indices.contains(indexPath.row) else { return cell }
		let pack = emojiHoarder.emojiPacks[indexPath.row]
		
		content.text = pack.name
		content.secondaryText = "\(pack.items.count) item\(pack.items.count.plural)"
		
		cell.contentConfiguration = content
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard emojiHoarder.emojiPacks.indices.contains(indexPath.row) else { return }
		let pack = emojiHoarder.emojiPacks[indexPath.row]
		
		if self.isEditing {
			
		} else {
			let detailView = EmojiPackDetailViewController(with: emojiHoarder, andPack: pack)
			self.navigationController?.pushViewController(detailView/*.collectionView*/, animated: true)
		}
	}
	
	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let pack = self.packFor(indexPath: indexPath) else { return nil }
		
		if let selectedRows = self.tableView.indexPathsForSelectedRows,
		   selectedRows.contains(indexPath) {
			let multiDelete = UIAction(
				title: "Delete \(selectedRows.count) pack\(selectedRows.count.plural)",
				image: UIImage(systemName: "trash"),
				attributes: .destructive
			) { action in
				self.multiDelete()
			}
			return UIContextMenuConfiguration(identifier: nil) {
//				return EmojiCollectionView(hoarder: self.emojiHoarder, items: pack.items, width: 50, style: .plain)
				return nil
			} actionProvider: { suggestedActions in
				return UIMenu(children: [multiDelete])
			}
		} else {
			let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
				self.delete(indexPath)
			}
			let duplicate = UIAction(title: "Duplicate", image: UIImage(systemName: "plus.square.fill.on.square.fill")) { action in
				self.dup(indexPath)
			}
			let share = UIAction(title: "Share...", image: UIImage(systemName: "square.and.arrow.up")) { action in
				self.share(indexPath)
			}
			let menu = UIMenu(children: [share, duplicate, delete])
			
			return UIContextMenuConfiguration(identifier: nil) {
				let grid = EmojiCollectionView(hoarder: self.emojiHoarder, items: pack.items, width: 50, style: .plain)
				let vc = UINavigationController(rootViewController: grid)
				
				let title = UILabel()
				title.text = pack.name
				title.font = .boldSystemFont(ofSize: title.font.pointSize)
				let subtitle = UILabel()
				subtitle.text = "\(pack.items.count) item\(pack.items.count.plural)"
				subtitle.textColor = .gray
				
				let stackView = UIStackView(arrangedSubviews: [title, subtitle])
				stackView.axis = .vertical
				stackView.alignment = .center
				stackView.spacing -= 2
				grid.navigationItem.titleView = stackView
				return vc
			} actionProvider: { suggestedActions in
				return menu
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		guard emojiHoarder.emojiPacks.indices.contains(indexPath.row) else { return nil }
		let pack = emojiHoarder.emojiPacks[indexPath.row]
		
		let delete = UIContextualAction(style: .destructive, title: "Delete") { contextualAction, view, closure in
			self.delete(indexPath)
		}
		delete.image = UIImage(systemName: "trash")
		
		let dupButton = UIContextualAction(style: .normal, title: "Duplicate") { contextualAction, view, closure in
			self.dup(indexPath)
		}
		dupButton.image = UIImage(systemName: "plus.square.fill.on.square.fill")
		
		let share = UIContextualAction(style: .normal, title: "Share") { contextualAction, view, closure in
			self.share(indexPath)
		}
		share.image = UIImage(systemName: "square.and.arrow.up")
		return UISwipeActionsConfiguration(actions: [delete, share, dupButton])
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.tableView.reloadData()
	}
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		self.navigationController?.setToolbarHidden(!editing, animated: true)
	}
	
	@objc func addPack() {
		emojiHoarder.newEmojiPack()
		self.tableView.insertRows(
			at: [IndexPath(row: tableView(self.tableView, numberOfRowsInSection: 0)-1, section: 0)],
			with: .automatic
		)
	}
	
	@objc func refresh(_ notification: Notification) {
//		self.tableView.reloadData()
	}
	
	func delete(_ indexPath: IndexPath) {
		guard let pack = packFor(indexPath: indexPath) else { return }
		
		self.emojiHoarder.removeEmojiPack(pack)
		self.tableView.deleteRows(at: [indexPath], with: .automatic)
	}
	
	@objc func multiDelete() {
		guard let selectedRows = self.tableView.indexPathsForSelectedRows else { return }
		
		var packs: [EmojiPack] = []
		for indexPath in selectedRows {
			guard let pack = packFor(indexPath: indexPath) else { return }
			packs.append(pack)
		}
		guard !packs.isEmpty else { return }
		
		for pack in packs {
			self.emojiHoarder.removeEmojiPack(pack)
		}
		self.tableView.deleteRows(at: selectedRows, with: .automatic)
		setEditing(false, animated: true)
	}
	
	func dup(_ indexPath: IndexPath) {
		guard let pack = packFor(indexPath: indexPath) else { return }
		
		self.emojiHoarder.addEmojiPack(pack)
		self.tableView.insertRows(
			at: [IndexPath(row: self.emojiHoarder.emojiPacks.count-1, section: 0)],
			with: .automatic
		)
	}
	
	func share(_ indexPath: IndexPath) {
		guard let pack = packFor(indexPath: indexPath) else { return }
		
		let itemProvider = NSItemProvider(item: pack.shareLink() as NSURL, typeIdentifier: UTType.url.identifier)
		let config = UIActivityItemsConfiguration(itemProviders: [itemProvider])
		let shareSheet = UIActivityViewController(activityItemsConfiguration: config)
		self.present(shareSheet, animated: true)
	}
	
	func packFor(indexPath: IndexPath) -> EmojiPack? {
		guard emojiHoarder.emojiPacks.indices.contains(indexPath.row) else { return nil }
		return emojiHoarder.emojiPacks[indexPath.row]
	}
}
