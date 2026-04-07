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
	
	@State var fromPackEditor: Bool = false
	@State var callback: ((String) -> Void) = { _ in }
	var minColWidth: CGFloat { 75 }
	var spacing: CGFloat { 10 }
	var col: GridItem {
		GridItem(
			.flexible(minimum: minColWidth, maximum: 100),
			spacing: spacing,
			alignment: .center
		)
	}
	
	var body: some View {
		NavigationStack {
			if fromPackEditor {
				GeometryReader { geo in
					let columns: Int = max(1, Int((geo.size.width - 2*spacing) / (minColWidth + spacing)))
					let layout = Array(repeating: col, count: columns)
					LazyVGrid(columns: layout, spacing: spacing) {
						ForEach(searchResult, id: \.self) { name in
							let emoji = hoarder.trie.dict[name] ?? .test
							StickerPreview(sticker: emoji)
								.onTapGesture {
									callback(emoji.name)
								}
						}
					}
				}
			} else {
				Picker("", selection: $stickerType) {
					ForEach(StickerType.allCases) { type in
						Text(type.description).tag(type)
					}
				}
				.pickerStyle(.segmented)
				switch stickerType {
				case .slackEmoji:
					EmojiTableView(hoarder: hoarder, items: searchResult)
						.id(searchResult)
						.ignoresSafeArea(edges: .bottom)
				case .giphyGifs:
					Text("uhh")
				}
			}
		}
		.searchable(text: $searchTerm)
		.onChange(of: searchTerm) { new in
			if currentSearch != nil { currentSearch?.cancel() }
			guard !searchTerm.isEmpty else {
				currentSearch?.cancel()
				searchResult = []
				previousSearches = []
				return
			}
			currentSearch = Task.detached {
				let result = await hoarder.trie.search(
					for: searchTerm,
					previousQuery: previousSearches.last,
					previousResult: Set(searchResult)
				)
				await MainActor.run {
					withAnimation(.snappy) {
						searchResult = result
						previousSearches.append(searchTerm)
					}
				}
			}
		}
	}
}

#Preview {
	SearchView(
		hoarder: EmojiHoarder(localOnly: true),
		fromPackEditor: true
	)
}
