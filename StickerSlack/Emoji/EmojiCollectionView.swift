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
	
	func makeUIView(context: Context) -> UITableView {
		let tableView = UITableView()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		tableView.dataSource = context.coordinator
		return tableView
	}
	
	func updateUIView(_ uiView: UITableView, context: Context) {
		uiView.reloadData()
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(hoarder: hoarder)
	}
	
	final class Coordinator: NSObject, UITableViewDataSource {
		var hoarder: EmojiHoarder
		
		init(hoarder: EmojiHoarder) {
			self.hoarder = hoarder
		}
		
		func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
			return hoarder.searchTerm.isEmpty ? hoarder.emojis.count : hoarder.filteredEmojis.count
		}
		
		func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
			var emojiName: String
			if hoarder.searchTerm.isEmpty {
				emojiName = hoarder.emojis[indexPath.row].name
			} else {
				emojiName = hoarder.filteredEmojis[indexPath.row]
			}
			let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
			
			cell.contentConfiguration = UIHostingConfiguration {
				HStack {
					EmojiPreview(
						hoarder: hoarder,
						emoji: hoarder.trie.dict[emojiName]!
					)
					.frame(maxWidth: 100, maxHeight: 100)
					Spacer()
					if hoarder.trie.dict[emojiName]!.isLocal {
						Button("", systemImage: "trash") {
							self.hoarder.trie.dict[emojiName]!.deleteImage()
							self.hoarder.trie.dict[emojiName]!.refresh()
							Haptic.heavy.trigger()
						}
						.buttonStyle(.plain)
					} else {
						Button("", systemImage: "arrow.down.circle") {
							Task.detached {
								try? await self.hoarder.trie.dict[emojiName]!.downloadImage()
								await MainActor.run {
									self.hoarder.trie.dict[emojiName]!.refresh()
									Haptic.success.trigger()
								}
							}
						}
						.buttonStyle(.plain)
					}
				}
			}
			return cell
		}
	}
}
