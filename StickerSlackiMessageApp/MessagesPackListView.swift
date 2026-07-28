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
	var onSelect: ((EmojiPack) -> Void)?
	
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
	
	override func viewDidLoad() {
//		self.splitViewController?.preferredPrimaryColumnWidth = UIScreen.main.bounds.width/4
		return
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return emojiHoarder.emojiPacks.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		var config = cell.defaultContentConfiguration()
		
		if let pack = packFor(indexPath: indexPath) {
			config.text = pack.name
			config.secondaryText = pack.description
			config.textProperties.font = UIFont.systemFont(ofSize: 14)
			config.secondaryTextProperties.font = UIFont.systemFont(ofSize: 14)
		}
		
		cell.contentConfiguration = config
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		onSelect?(emojiHoarder.emojiPacks[indexPath.row])
	}
}
