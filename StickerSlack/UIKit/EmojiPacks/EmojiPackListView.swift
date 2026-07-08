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
	var multiDeleteLabel: UIBarButtonItem!
	
	init(emojiHoarder: EmojiHoarder) {
		self.emojiHoarder = emojiHoarder
		super.init(style: .insetGrouped)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func showRenamer(for indexPath: IndexPath) {
		guard let pack = packFor(indexPath: indexPath) else { return }
		let alert = UIAlertController(title: "Rename Pack", message: nil, preferredStyle: .alert)
		alert.addTextField { textField in
			textField.text = pack.name
			textField.placeholder = pack.name
			//			textField.borderStyle = .
		}
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
			self.dismiss(animated: true)
		}))
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
			defer { self.dismiss(animated: true) }
			
			var editedPack = pack
			guard let textField = alert.textFields?.first,
				  let text = textField.text else { return }
			
			editedPack.name = text
			self.emojiHoarder.updateEmojiPack(editedPack)
			self.setEditing(false, animated: true)
			self.refresh()
		}))
		alert.preferredAction = alert.actions.last
		self.present(alert, animated: true)
	}
	
	@objc func addPack() {
		emojiHoarder.newEmojiPack()
		self.tableView.insertRows(
			at: [IndexPath(row: tableView(self.tableView, numberOfRowsInSection: 0)-1, section: 0)],
			with: .automatic
		)
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
	
	func updateMultiDeleteButton() {
		if let selectedRows = self.tableView.indexPathsForSelectedRows,
		   !selectedRows.isEmpty {
			self.multiDeleteButton.isEnabled = true
			self.multiDeleteLabel.title = "\(selectedRows.count)"
		} else {
			self.multiDeleteButton.isEnabled = false
			self.multiDeleteLabel.title = "0"
		}
	}
	
	func refresh() {
		self.tableView.reloadData()
	}
	
	override func viewDidLoad() {
		self.tableView.allowsMultipleSelectionDuringEditing = true
		self.navigationItem.title = "Packs"
		
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(
			image: UIImage(systemName: "plus"),
			style: .plain,
			target: self,
			action: #selector(addPack)
		)
		
		self.navigationItem.rightBarButtonItem = self.editButtonItem
		self.multiDeleteLabel = UIBarButtonItem(title: "X", style: .plain, target: self, action: nil)
		self.multiDeleteButton = UIBarButtonItem(
			image: UIImage(systemName: "trash"),
			style: .plain,
			target: self,
			action: #selector(multiDelete)
		)
		self.multiDeleteButton.tintColor = .systemRed
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		refresh()
	}
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		updateMultiDeleteButton()
		var items: [UIBarButtonItem] = [self.editButtonItem]
		if editing {
			items.append(contentsOf: [multiDeleteLabel, multiDeleteButton])
		}
		self.navigationItem.setRightBarButtonItems(items, animated: true)
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return emojiHoarder.emojiPacks.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		var content = cell.defaultContentConfiguration()
		
		guard let pack = packFor(indexPath: indexPath) else { return cell }
		
		content.text = pack.name
		content.secondaryText = "\(pack.items.count) emoji\(pack.items.count.plural)"
		cell.contentConfiguration = content
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let pack = packFor(indexPath: indexPath) else { return }
		
		if !self.isEditing {
			let detailView = EmojiPackDetailViewController(with: emojiHoarder, andPack: pack)
			self.navigationController?.pushViewController(detailView, animated: true)
			return
		}
		updateMultiDeleteButton()
	}
	
	override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		updateMultiDeleteButton()
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
				return nil
			} actionProvider: { suggestedActions in
				return UIMenu(children: [multiDelete])
			}
		} else {
			let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
				self.delete(indexPath)
			}
			let rename = UIAction(title: "Rename", image: UIImage(systemName: "pencil")) { action in
				self.showRenamer(for: indexPath)
			}
			let duplicate = UIAction(title: "Duplicate", image: UIImage(systemName: "plus.square.fill.on.square.fill")) { action in
				self.dup(indexPath)
			}
//			UIMenu(options: .displayInline, children: [delete])
			let share = UIAction(title: "Share...", image: UIImage(systemName: "square.and.arrow.up")) { action in
				self.share(indexPath)
			}
			let isDownloaded = pack.allDownloaded(in: emojiHoarder)
			let download = UIAction(
				title: "\(isDownloaded ? "Remove " : "")Download",
				image: UIImage(systemName: isDownloaded ? "trash" : "arrow.down")
			) { action in
				Task {
					if isDownloaded {
						await pack.deleteAll(hoarder: self.emojiHoarder)
					} else {
						await pack.downloadAll(hoarder: self.emojiHoarder)
					}
				}
			}
			let submenu = UIMenu(options: .displayInline, children: [rename, duplicate, share])
			let menu = UIMenu(children: [download, submenu, delete])
			
			return UIContextMenuConfiguration(identifier: nil) {
				let grid = EmojiCollectionView(hoarder: self.emojiHoarder, items: pack.items, width: 50, style: .plain)
				let vc = UINavigationController(rootViewController: grid)
				
				let title = UILabel()
				title.text = pack.name
				title.font = .boldSystemFont(ofSize: title.font.pointSize)
				let subtitle = UILabel()
				subtitle.text = "\(pack.items.count) emoji\(pack.items.count.plural)"
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
		guard packFor(indexPath: indexPath) != nil else { return nil }
		
		let delete = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
			self.delete(indexPath)
		}
		delete.image = UIImage(systemName: "trash")
		
		let dupButton = UIContextualAction(style: .normal, title: "Duplicate") { _, _, _ in
			self.dup(indexPath)
		}
		dupButton.image = UIImage(systemName: "plus.square.fill.on.square.fill")
		
		let rename = UIContextualAction(style: .normal, title: "Rename") { _, _, _ in
			self.showRenamer(for: indexPath)
		}
		rename.image = UIImage(systemName: "pencil")
		
		let share = UIContextualAction(style: .normal, title: "Share") { _, _, _ in
			self.share(indexPath)
		}
		share.image = UIImage(systemName: "square.and.arrow.up")
		return UISwipeActionsConfiguration(actions: [delete, dupButton, rename, share])
	}
	
}
