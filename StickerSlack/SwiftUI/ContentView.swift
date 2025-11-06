//
//  ContentView.swift
//  StickerSlack
//
//  Created by neon443 on 15/10/2025.
//

import SwiftUI
import Haptics

struct ContentView: View {
	@StateObject var hoarder: EmojiHoarder = .shared
	
	@State var searchTerm: String = ""
	
	var minColWidth: CGFloat { 75 }
	var spacing: CGFloat { 10 }
	var col: GridItem {
		GridItem(
			.flexible(minimum: minColWidth, maximum: 125),
			spacing: spacing,
			alignment: .center
		)
	}
	
	@Environment(\.colorScheme) var colorScheme
	var isDark: Bool { colorScheme == .dark }
	var body: some View {
		TabView {
			ScrollView {
				let columns: Int = max(1, Int((UIScreen.main.bounds.width - 2*spacing) / (minColWidth + spacing)))
				let layout = Array(repeating: col, count: columns)
				LazyVGrid(columns: layout, spacing: 10) {
					ForEach(hoarder.emojis, id: \.self) { emoji in
						if hoarder.downloadedEmojis.contains(emoji.name) {
							ZStack {
								Rectangle()
									.foregroundStyle(isDark ? .black : .white)
								EmojiPreview(emoji: emoji)
								RoundedRectangle(cornerRadius: 15)
									.stroke(.gray, lineWidth: 1)
							}
							.aspectRatio(1, contentMode: .fit)
							.clipShape(RoundedRectangle(cornerRadius: 15))
							.contextMenu {
								Text(emoji.name)
								Button("Share", systemImage: "square.and.arrow.up") {
									
								}
								ShareLink("Share", item: emoji.localImageURL, subject: nil, message: nil)
								ShareLink("Share", item: emoji.remoteImageURL, subject: nil, message: nil)
								Divider()
								Button("Delete", systemImage: "trash.fill", role: .destructive) {
									hoarder.delete(emoji: emoji)
								}
							}
						}
					}
				}
				.padding(.horizontal, spacing)
			}
			.tabItem {
				Label("Downloaded", systemImage: "arrow.down.circle.fill")
			}
			
			List {
				ForEach(hoarder.emojis, id: \.self) { emoji in
					EmojiRow(emoji: emoji)
				}
			}
			.tabItem {
				Label("Browse", systemImage: "square.grid.2x2.fill")
			}
			
			List {
				Text("\(searchTerm.isEmpty ? hoarder.emojis.count : hoarder.filteredEmojis.count) Emoji")
				
				ForEach(hoarder.filteredEmojis, id: \.self) { name in
					if let emoji = hoarder.trie.dict[name] {
						EmojiRow(emoji: emoji)
					}
				}
			}
			.onChange(of: searchTerm) { _ in
				hoarder.filterEmojis(by: searchTerm)
			}
			.refreshable {
				Task.detached {
					await hoarder.refreshDB()
				}
				searchTerm = ""
			}
			.tabItem {
				Label("Search", systemImage: "magnifyingglass")
			}
			
			TrieTestingView()
				.tabItem {
					Label("Tree", systemImage: "tree.fill")
				}
		}
		.searchable(text: $searchTerm, placement: .automatic)
	}
}

#Preview {
	ContentView(hoarder: EmojiHoarder(localOnly: true))
}
