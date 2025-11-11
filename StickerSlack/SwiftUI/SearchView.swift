//
//  SearchView.swift
//  StickerSlack
//
//  Created by neon443 on 10/11/2025.
//

import SwiftUI

struct SearchView: View {
	@ObservedObject var hoarder: EmojiHoarder
	
    var body: some View {
		List {
			Text("\(hoarder.searchTerm.isEmpty ? hoarder.emojis.count : hoarder.filteredEmojis.count) Emoji")
			
			ForEach(hoarder.filteredEmojis, id: \.self) { name in
				if let emoji = hoarder.trie.dict[name] {
					EmojiRow(hoarder: hoarder, emoji: emoji)
				}
			}
		}
		.onChange(of: hoarder.searchTerm) { _ in
			hoarder.filterEmojis(by: hoarder.searchTerm)
		}
	}
}

#Preview {
    SearchView(hoarder: EmojiHoarder(localOnly: true))
}
