//
//  SearchView.swift
//  StickerSlack
//
//  Created by neon443 on 10/11/2025.
//

import SwiftUI

struct SearchView: View {
	@ObservedObject var hoarder: EmojiHoarder
	
	@State var searchTerm: String = ""
	@State var searchResult: [String] = []
	
	@State private var currentSearch: Task<Void, Never>?
	
	var body: some View {
		NavigationStack {
			List(searchResult, id: \.self) { name in
				EmojiRow(hoarder: hoarder, emoji: hoarder.trie.dict[name]!)
			}
		}
		.onChange(of: searchTerm) { _ in
			if currentSearch != nil { currentSearch?.cancel() }
			currentSearch = Task.detached {
				let result = await hoarder.trie.search(for: searchTerm)
				await MainActor.run {
					withAnimation(.snappy) {
						searchResult = result
					}
				}
			}
		}
		.searchable(text: $searchTerm)
	}
}

#Preview {
	SearchView(hoarder: EmojiHoarder(localOnly: true))
}
