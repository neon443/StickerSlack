//
//  SearchView.swift
//  StickerSlack
//
//  Created by neon443 on 10/11/2025.
//

import SwiftUI

struct SearchView: View {
	@ObservedObject var hoarder: EmojiHoarder
	
	@State var filterResult: [String] = []
	
	var body: some View {
		NavigationStack {
			List {
				Text("\(hoarder.searchTerm.isEmpty ? hoarder.emojis.count : filterResult.count) Emoji")
				
				ForEach(filterResult, id: \.self) { name in
					if let emoji = hoarder.trie.dict[name] {
						EmojiRow(hoarder: hoarder, emoji: emoji)
					}
				}
			}
			.onChange(of: hoarder.searchTerm) { _ in
				filterResult = hoarder.trie.search(prefix: hoarder.searchTerm)
			}
		}
		.searchable(text: $hoarder.searchTerm)
	}
}

#Preview {
    SearchView(hoarder: EmojiHoarder(localOnly: true))
}
