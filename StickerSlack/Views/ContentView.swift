//
//  ContentView.swift
//  StickerSlack
//
//  Created by neon443 on 15/10/2025.
//

import SwiftUI
import Haptics

struct ContentView: View {
	@StateObject var hoarder: EmojiHoarder = EmojiHoarder()
	
	@State var searchTerm: String = ""
	
	var body: some View {
		TabView {
			List {
				ForEach(hoarder.downloadedEmojis, id: \.self) { name in
					if let emoji = hoarder.trie.dict[name] {
						EmojiRow(hoarder: hoarder, emoji: emoji)
					}
				}
			}
			.tabItem {
				Label("Downloaded", systemImage: "arrow.down.circle.fill")
			}
			
			List {
				ForEach(hoarder.emojis, id: \.self) { emoji in
					EmojiRow(hoarder: hoarder, emoji: emoji)
				}
			}
			.tabItem {
				Label("Browse", systemImage: "square.grid.2x2.fill")
			}
			
			NavigationView {
				List {
					Text("\(searchTerm.isEmpty ? hoarder.emojis.count : hoarder.filteredEmojis.count) Emoji")
					
					ForEach(hoarder.filteredEmojis, id: \.self) { name in
						if let emoji = hoarder.trie.dict[name] {
							EmojiRow(hoarder: hoarder, emoji: emoji)
						}
					}
				}
				.navigationTitle("StickerSlack")
				.onChange(of: searchTerm) { _ in
					hoarder.filterEmojis(by: searchTerm)
				}
				.refreshable {
					Task.detached {
						await hoarder.refreshDB()
					}
					searchTerm = ""
				}
			}
			.tabItem {
				Label("Search", systemImage: "magnifyingglass")
			}
			
			TrieTestingView(
				hoarder: hoarder,
			)
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
