//
//  SearchView.swift
//  StickerSlack
//
//  Created by neon443 on 10/11/2025.
//

import SwiftUI

struct SearchView: View {
	@ObservedObject var hoarder: EmojiHoarder
	
	@State private var currentSearch: Task<Void, Never>?
	@State var searchTerm: String = ""
	@State var searchResult: [String] = []
	
	var body: some View {
		NavigationStack {
			List {
				Text("\(searchResult.count) Result\(searchResult.count.plural)")
					.contentTransition(.numericText())
				ForEach(searchResult, id: \.self) { name in
					StickerRow(hoarder: hoarder, emoji: hoarder.trie.dict[name]!)
				}
			}
		}
		.searchable(text: $searchTerm)
		.onChange(of: searchTerm) { _ in
			guard !searchTerm.isEmpty else {
				currentSearch?.cancel()
				withAnimation { searchResult = [] }
				return
			}
			if currentSearch != nil {
				withAnimation { currentSearch?.cancel() }
			}
//			currentSearch = Task {
				let result = hoarder.trie.search(for: searchTerm)
				guard !Task.isCancelled else { return }
//				await MainActor.run {
					withAnimation(.snappy) {
						searchResult = result
					}
//				}
//			}
		}
	}
}

#Preview {
	SearchView(hoarder: EmojiHoarder(localOnly: true))
}
