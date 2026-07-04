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
	@State private var searchTerm: String = ""
	@State var previousSearches: [String] = []
	@State private var searchResult: [String] = []
	
	@State var fromPackEditor: Bool = false
	@State var callback: ((String) -> Void) = { _ in }
	
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
			if searchTerm.isEmpty {
				EmptyCollectionView(title: "Start a Search", details: nil, systemImage: "magnifyingglass")
					.frame(maxHeight: 100)
				Spacer()
			} else if searchResult.isEmpty {
				EmptyCollectionView(title: "No Results", details: "Try a new search", systemImage: "exclamationmark.magnifyingglass")
					.frame(maxHeight: 100)
				Spacer()
			} else if fromPackEditor {
				EmojiCollectionViewRepresentable(
					hoarder: hoarder,
					items: searchResult,
					width: 75,
					style: .plainWithLabel,
					onTapCallback: { callback($0)
					})
			} else {
				EmojiTableViewRepresentable(hoarder: hoarder, items: searchResult)
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
		fromPackEditor: true
	) {
		print($0)
	}
}
