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
			List(filterResult, id: \.self) { name in
				EmojiRow(hoarder: hoarder, emoji: hoarder.trie.dict[name]!)
			}
			.onChange(of: hoarder.searchTerm) { _ in
				withAnimation { filterResult = hoarder.trie.search(prefix: hoarder.searchTerm) }
			}
		}
		.searchable(text: $hoarder.searchTerm)
	}
}

#Preview {
    SearchView(hoarder: EmojiHoarder(localOnly: true))
}
