//
//  EmojiCollectionView.swift
//  StickerSlack
//
//  Created by neon443 on 03/11/2025.
//

import Foundation
import UIKit
import SwiftUI
import Haptics

struct EmojiCollectionView: UIViewRepresentable {
	let hoarder: EmojiHoarder
	let items: [String]
	
	func makeUIView(context: Context) -> UITableView {
		let tableView = context.coordinator as UITableViewController
		tableView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		tableView.tableView.dataSource = context.coordinator
		tableView.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
		tableView.tableView.separatorStyle = .none
		return tableView.tableView
	}
	
	func updateUIView(_ uiView: UITableView, context: Context) {
		context.coordinator.hoarder = hoarder
		context.coordinator.items = items
		uiView.reloadData()
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(hoarder: hoarder, items: items)
	}
	
	final class Coordinator: UITableViewController {
		var hoarder: EmojiHoarder
		var items: [String]
		
		init(hoarder: EmojiHoarder, items: [String]) {
			self.hoarder = hoarder
			self.items = items
			super.init(style: .insetGrouped)
		}
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
			return items.count
		}
		
		override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
			guard !hoarder.trie.dict.isEmpty else {
				let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
				let spinner = UIActivityIndicatorView()
				spinner.startAnimating()
				spinner.style = .large
				spinner.frame = cell.frame
				spinner.autoresizingMask = .flexibleWidth
				cell.addSubview(spinner)
				tableView.reloadData()
				return cell
			}
			let emojiName = items[indexPath.row]
			let emoji = hoarder.trie.dict[emojiName]!
			let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
			
			cell.selectedBackgroundView = nil
			cell.selectionStyle = .none
			cell.contentConfiguration = UIHostingConfiguration {
				StickerRow(hoarder: hoarder, sticker: emoji)
					.id(emoji)
			}
			return cell
		}
		
		override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//			<#code#>
		}
		
		override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//			<#code#>
		}
		
		override func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
			return true
		}
	}
}
//
//class EmojiCell: UITableViewCell {
//	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//		let l = UILabel()
//		l.text = "ifosa"
//		self.view = l
//	}
//	
//	required init?(coder: NSCoder) {
//		fatalError("init(coder:) has not been implemented")
//	}
//}
