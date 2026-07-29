//
//  MessagesSplitViewController.swift
//  StickerSlackiMessageApp
//
//  Created by neon443 on 24/07/2026.
//

import Foundation
import UIKit
import Messages

class MessagesSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
	var emojiHoarder: EmojiHoarder!
	var tableView: MessagesPackListView!
	
	init(hoarder: EmojiHoarder) {
		self.emojiHoarder = hoarder
		self.tableView = MessagesPackListView(hoarder: hoarder)
		super.init(style: .doubleColumn)
		tableView.onSelect = { pack in
			let browser = MSStickerBrowserView(frame: .zero, stickerSize: .small)
			let dataSource = StickerBrowserDataSource(hoarder: hoarder, pack: pack)
			browser.dataSource = dataSource
			let vc = MessagesAppViewController(nibName: nil, bundle: nil)
			browser.translatesAutoresizingMaskIntoConstraints = false
			vc.view.addSubview(browser)
			browser.contentInset = .zero
			NSLayoutConstraint.activate([
				browser.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
				browser.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
				browser.topAnchor.constraint(equalTo: vc.view.topAnchor),
				browser.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor)
			])
			self.setViewController(vc, for: .secondary)
		}
		self.preferredSplitBehavior = .tile
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		self.setViewController(tableView, for: .primary)
		self.setViewController(MessagesPackListView(hoarder: emojiHoarder), for: .secondary)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	
	//	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
	//		return emojiHoarder.emojiPacks.count
	//	}
	//
	//	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
	//		<#code#>
	//	}
	//
	//	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
	//		<#code#>
	//	}
}
