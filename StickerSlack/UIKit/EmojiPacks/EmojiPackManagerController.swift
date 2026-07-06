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
	
	override func pushViewController(_ viewController: UIViewController, animated: Bool) {
		super.pushViewController(viewController, animated: animated)
		setToolbar(forViewController: viewController)
	}
	
	override func popViewController(animated: Bool) -> UIViewController? {
		let vc = super.popViewController(animated: animated)
		setToolbar(forViewController: vc)
		return vc
	}
	
	func setToolbar(forViewController vc: UIViewController?) {
		guard let vc else { return }
		if vc == tableView {
			self.setToolbarHidden(true, animated: true)
		} else {
			self.setToolbarHidden(false, animated: true)
		}
	}
}
