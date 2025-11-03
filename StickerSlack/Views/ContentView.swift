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
		NavigationView {
			List {
				NavigationLink("trieTester") {
					TrieTestingView(
						hoarder: hoarder,
					)
				}
				
				Text("\(searchTerm.isEmpty ? hoarder.emojis.count : hoarder.filteredEmojis.count) Emoji")
				
				if searchTerm.isEmpty {
					ForEach($hoarder.emojis, id: \.self) { $emoji in
						EmojiRow(hoarder: hoarder, emoji: emoji)
					}
				} else {
					ForEach(hoarder.filteredEmojis, id: \.self) { name in
						if let emoji = hoarder.trie.dict[name] {
							EmojiRow(hoarder: hoarder, emoji: emoji)
						}
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
		.searchable(text: $searchTerm, placement: .automatic)
	}
}

#Preview {
	ContentView(hoarder: EmojiHoarder(localOnly: true))
}
