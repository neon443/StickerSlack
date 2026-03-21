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
	@State var previousSearches: [String] = []
	@State var searchResult: [String] = []
	
	@State var stickerType: StickerType = .slackEmoji
	
	var body: some View {
		NavigationStack {
			Picker("", selection: $stickerType) {
				ForEach(StickerType.allCases) { type in
					Text(type.description).tag(type)
				}
			}
			.pickerStyle(.segmented)
			switch stickerType {
			case .slackEmoji:
				List {
					Text("\(searchResult.count) Result\(searchResult.count.plural)")
						.contentTransition(.numericText())
					ForEach(searchResult, id: \.self) { name in
						StickerRow(hoarder: hoarder, emoji: hoarder.trie.dict[name]!)
					}
				}
				.fixedSize()
				EmojiCollectionView(hoarder: hoarder, items: searchResult)
					.id(searchResult)
			case .giphyGifs:
				Text("uhh")
			}
		}
		.searchable(text: $searchTerm)
		.onChange(of: searchTerm) { new in
			if currentSearch != nil { currentSearch?.cancel() }
			guard !searchTerm.isEmpty else {
				currentSearch?.cancel()
				searchResult = []
				previousSearches.append(searchTerm)
				return
			}
			currentSearch = Task.detached {
				let result = await hoarder.trie.search(
					for: searchTerm,
					previousQuery: previousSearches.last,
					previousResult: Set(searchResult)
				)
				await MainActor.run {
					withAnimation {
						searchResult = result
						previousSearches.append(searchTerm)
					}
				}
			}
		}
	}
}

#Preview {
	SearchView(hoarder: EmojiHoarder(localOnly: true))
}
