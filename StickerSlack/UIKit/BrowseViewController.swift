//
//  BrowseViewController.swift
//  StickerSlack
//
//  Created by neon443 on 07/07/2026.
//

import Foundation
import UIKit

class BrowseViewController: UINavigationController {
	var emojiHoarder: EmojiHoarder
	var tableView: EmojiTableView
	
	init(emojiHoarder: EmojiHoarder) {
		self.emojiHoarder = emojiHoarder
		self.tableView = EmojiTableView(hoarder: emojiHoarder, items: [])
		super.init(rootViewController: self.tableView)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(refreshUI),
			name: EmojiHoarder.NotifCategory.emojis.name,
			object: nil
		)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		refreshUI()
	}
	
	func getItems() -> [String] {
		return emojiHoarder.emojis.map { $0.name }
	}
	
	@objc func refreshUI(withItems items: [String]? = nil) {
		tableView.navigationItem.title = "Browse"
		tableView.navigationItem.rightBarButtonItem = UIBarButtonItem(
			image: UIImage(systemName: "shuffle"),
			style: .plain,
			target: self,
			action: #selector(shuffle)
		)
		if let items,
		   !items.isEmpty {
			tableView.refreshUI(with: items)
		} else {
			tableView.refreshUI(with: getItems())
		}
	}
	
	@objc func shuffle() {
		self.refreshUI(withItems: getItems().shuffled())
	}
}
