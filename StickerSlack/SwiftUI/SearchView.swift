//
//  SearchView.swift
//  StickerSlack
//
//  Created by neon443 on 10/11/2025.
//

import SwiftUI

struct SearchView: View {
	@ObservedObject var hoarder: EmojiHoarder
	
	@FocusState private var searchFocused: Bool
	@State private var currentSearch: Task<Void, Never>?
	@Binding var searchTerm: String
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
	
	@Environment(\.dismiss) var dismiss
	
	func runSearch(with: String) {
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
	
	var body: some View {
		VStack {
			if fromPackEditor {
				EmojiCollectionView(
					hoarder: hoarder,
					items: searchResult,
					width: 75,
					style: .plainWithLabel,
					onTapCallback: { callback($0)
					})
			} else {
				switch stickerType {
				case .slackEmoji:
					Text("\(searchResult.count)")
					EmojiTableView(hoarder: hoarder, items: searchResult)
						.padding(.bottom, 10)
				case .giphyGifs:
					Text("uhh")
				}
				Picker("", selection: $stickerType) {
					ForEach(StickerType.allCases) { type in
						Text(type.description).tag(type)
					}
				}
				.pickerStyle(.segmented)
				.padding(.horizontal)
			}
		}
		.searchable(text: $searchTerm)
		.onChange(of: searchTerm) { new in
			runSearch(with: new)
		}
		.onAppear {
			guard !searchTerm.isEmpty else { return }
			runSearch(with: searchTerm)
		}
	}
}

@available(iOS 17, *)
#Preview {
	@Previewable @State var searchTerm: String = ""
	
	SearchView(
		hoarder: EmojiHoarder(localOnly: true),
		searchTerm: $searchTerm,
		fromPackEditor: true
	) {
		print($0)
	}
}
