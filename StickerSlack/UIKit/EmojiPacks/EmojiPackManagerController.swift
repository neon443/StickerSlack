//
//  EmojiPackManagerController.swift
//  StickerSlack
//
//  Created by neon443 on 05/07/2026.
//

import Foundation
import UIKit

class EmojiPackManagerController: UINavigationController, UINavigationControllerDelegate {
	var emojiHoarder: EmojiHoarder
	var tableView: UITableViewController
	
	init(emojiHoarder: EmojiHoarder) {
		self.emojiHoarder = emojiHoarder
		self.tableView = EmojiPackListView(emojiHoarder: emojiHoarder)
		super.init(rootViewController: tableView)
		self.isToolbarHidden = false
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
