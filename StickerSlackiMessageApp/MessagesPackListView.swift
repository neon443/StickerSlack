//
//  MessagesPackListView.swift
//  StickerSlackiMessageApp
//
//  Created by neon443 on 24/07/2026.
//

import Foundation
import UIKit

class MessagesPackListView: UITableViewController {
	var emojiHoarder: EmojiHoarder!
	var onSelect: ((EmojiPack?) -> Void)?
	
	init(hoarder: EmojiHoarder) {
		self.emojiHoarder = hoarder
		super.init(style: .plain)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func packFor(indexPath: IndexPath) -> EmojiPack? {
		guard emojiHoarder.emojiPacks.indices.contains(indexPath.row) else { return nil }
		return emojiHoarder.emojiPacks[indexPath.row]
	}
	
	@objc func reload() {
		var indexPaths: [IndexPath] = []
		for row in 0..<tableView(tableView, numberOfRowsInSection: 1) {
			indexPaths.append(IndexPath(row: row, section: 1))
		}
		tableView.reconfigureRows(at: indexPaths)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		let selRow = UserDefaults.standard.integer(forKey: "selectedPackRowIndex")
		let indexPath: IndexPath
		if selRow == -1 {
			indexPath = IndexPath(row: 0, section: 0)
		} else {
			indexPath = IndexPath(row: selRow, section: 1)
		}
		tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
		reload()
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 1 {
			return emojiHoarder.emojiPacks.count
		} else {
			return 1
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: UITableViewCell = tableView.cellForRow(at: indexPath) ?? .init()
		
		guard indexPath.section == 1 else {
			var config = cell.defaultContentConfiguration()
			
			config.text = "All"
			config.textProperties.font = UIFont.systemFont(ofSize: 14)
			config.textProperties.color = #colorLiteral(red: 0.7490000129, green: 0.3529999852, blue: 0.949000001, alpha: 1)
			
			let dlCount = emojiHoarder.downloadedStickers.count
			config.secondaryText = "\(dlCount) download\(dlCount.plural)"
			config.secondaryTextProperties.font = UIFont.systemFont(ofSize: 12)
			config.secondaryTextProperties.color = #colorLiteral(red: 0.7490000129, green: 0.3529999852, blue: 0.949000001, alpha: 1)
			
			cell.contentConfiguration = config
			return cell
		}
		var config = cell.defaultContentConfiguration()
		
		if let pack = packFor(indexPath: indexPath) {
			config.text = pack.name
			config.textProperties.font = UIFont.systemFont(ofSize: 14)
			
			let dlCount = emojiHoarder.downloadedStickers.intersection(pack.items).count
			config.secondaryText = pack.downloadedDescription(dlCount)
			
			config.secondaryTextProperties.font = UIFont.systemFont(ofSize: 12)
			config.secondaryTextProperties.color = .systemGray
		}
		
		cell.contentConfiguration = config
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 1 {
			onSelect?(emojiHoarder.emojiPacks[indexPath.row])
			UserDefaults.standard.set(indexPath.row, forKey: "selectedPackRowIndex")
		} else {
			onSelect?(nil)
			UserDefaults.standard.set(-1, forKey: "selectedPackRowIndex")
		}
	}
}
