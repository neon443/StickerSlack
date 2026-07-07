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
			selector: #selector(refresh),
			name: EmojiHoarder.NotifCategory.emojis.name,
			object: nil
		)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		refresh()
	}
	
	@objc func refresh() {
		tableView.navigationItem.title = "Browse"
		tableView.refreshUI(with: emojiHoarder.emojis.map{ $0.name })
	}
}
