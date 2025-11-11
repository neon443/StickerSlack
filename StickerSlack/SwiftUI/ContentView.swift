//
//  ContentView.swift
//  StickerSlack
//
//  Created by neon443 on 15/10/2025.
//

import SwiftUI
import Haptics

struct ContentView: View {
	@ObservedObject var hoarder: EmojiHoarder = EmojiHoarder()
	
	var body: some View {
		if #available(iOS 18, *) {
			TabView {
				Tab("Browse", systemImage: "square.grid.2x2.fill") {
					BrowseView(hoarder: hoarder)
				}
				
				//					Tab {
				//						List {
				//							Text("\(searchTerm.isEmpty ? hoarder.emojis.count : hoarder.filteredEmojis.count) Emoji")
				//
				//							ForEach(hoarder.filteredEmojis, id: \.self) { name in
				//								if let emoji = hoarder.trie.dict[name] {
				//									EmojiRow(emoji: emoji)
				//								}
				//							}
				//						}
				//						.onChange(of: searchTerm) { _ in
				//							hoarder.filterEmojis(by: searchTerm)
				//						}
				//						.refreshable {
				//							Task.detached {
				//								await hoarder.refreshDB()
				//							}
				//							searchTerm = ""
				//						}
				//					} label: {
				//						Label("Search", systemImage: "magnifyingglass")
				//					}
				
				Tab("Downloaded", systemImage: "arrow.down.circle.fill") {
					DownloadedView(hoarder: hoarder)
				}
				
				Tab("Tree", systemImage: "tree.fill") {
					TrieTestingView(hoarder: hoarder)
				}
				
				Tab(role: .search) {
					SearchView(hoarder: hoarder)
				}
			}
		} else {
			TabView {
				DownloadedView(hoarder: hoarder)
					.tabItem {
						Label("Downloaded", systemImage: "arrow.down.circle.fill")
					}
				BrowseView(hoarder: hoarder)
					.tabItem {
						Label("Browse", systemImage: "square.grid.2x2.fill")
					}
				TrieTestingView(hoarder: hoarder)
					.tabItem {
						Label("Trie", systemImage: "tree.fill")
					}
				SearchView(hoarder: hoarder)
					.tabItem {
						Label("Search", systemImage: "magnifyingglass")
					}
			}
		}
	}
}

#Preview {
	ContentView(hoarder: EmojiHoarder(localOnly: true))
}
