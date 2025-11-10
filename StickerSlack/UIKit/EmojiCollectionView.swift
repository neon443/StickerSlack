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
	let hoarder: EmojiHoarder = .shared
	let items: [String]
	
	func makeUIView(context: Context) -> UITableView {
		let tableView = UITableView()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		tableView.dataSource = context.coordinator
		return tableView
	}
	
	func updateUIView(_ uiView: UITableView, context: Context) {
		context.coordinator.hoarder = hoarder
		context.coordinator.items = items
		uiView.reloadData()
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(items: items)
	}
	
	final class Coordinator: NSObject, UITableViewDataSource {
		var hoarder: EmojiHoarder = .shared
		var items: [String]
		
		init(items: [String]) {
			self.items = items
		}
		
		func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
			return items.count
		}
		
		func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
			let emojiName = items[indexPath.row]
			let emoji = hoarder.trie.dict[emojiName]!
			let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
			
			cell.contentConfiguration = UIHostingConfiguration {
				HStack {
					EmojiPreview(
						hoarder: hoarder,
						emoji: emoji
					)
					.frame(maxWidth: 100, maxHeight: 100)
					Spacer()
					if hoarder.downloadedEmojis.contains(emojiName) {
						Button("", systemImage: "trash") {
							fatalError()
						}
						.buttonStyle(.plain)
					} else {
						Button("", systemImage: "arrow.down.circle") {
							self.hoarder.download(emoji: emoji)
						}
						.buttonStyle(.plain)
					}
				}
			}
			return cell
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
