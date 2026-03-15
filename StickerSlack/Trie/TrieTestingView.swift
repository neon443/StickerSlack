//
//  TrieTestingView.swift
//  StickerSlack
//
//  Created by neon443 on 03/11/2025.
//

import SwiftUI

struct TrieTestingView: View {
	@ObservedObject var hoarder: EmojiHoarder 
	
	@State private var searchTask: Task<Void, Never>?
	@State var searchTerm: String = ""
	@State var searchResults: [String] = []
	@State var exactSearchResult: Bool? = nil
	
	@State var uikit: Bool = false
	
	@State private var searchType: SearchType = .contains
	private enum SearchType: String, CaseIterable {
		case trie = "trie"
		case contains = "contains"
		case exact = "exact"
	}
	
	private func runSearch() {
		searchResults = []
		exactSearchResult = nil
		guard !searchTerm.isEmpty else { return }
		switch searchType {
		case .trie:
			withAnimation(.snappy) {
				searchResults = hoarder.trie.search(prefix: searchTerm)
			}
			print("testing: trie search complete")
		case .contains:
			if searchTask != nil { searchTask?.cancel() }
			searchTask = Task.detached {
				let result = await hoarder.trie.search(for: searchTerm)
				await MainActor.run {
					withAnimation(.snappy) { searchResults = result }
					print("testing: contains search complete")
				}
			}
		case .exact:
			withAnimation(.snappy) {
				exactSearchResult = hoarder.trie.search(exactly: searchTerm)
			}
			print("testing: exact search complete")
		}
	}
	
	var body: some View {
		VStack {
			Toggle("uikit list!!", isOn: $uikit)
				.foregroundStyle(.blue)
			
			HStack {
				Button("reset", role: .destructive) {
					hoarder.resetAllIndexes()
				}
				Spacer()
				Button("add emojis!") {
					hoarder.buildTrie()
				}
				.buttonStyle(.borderedProminent)
			}
			
			Picker("", selection: $searchType) {
				ForEach(SearchType.allCases, id: \.self) { typee in
					Text(typee.rawValue).tag(typee)
				}
			}
			.pickerStyle(.segmented)
			.onChange(of: searchType.rawValue+searchTerm) { _ in
				runSearch()
			}

			if searchType == .exact {
				HStack {
					TextField("", text: $searchTerm)
						.textFieldStyle(.roundedBorder)
						.border(.orange)
					if let exactSearchResult {
						Circle()
							.frame(width: 20, height: 20)
							.foregroundStyle(exactSearchResult ? .green : .red)
					} else {
						Text("?")
							.frame(width: 20, height: 20)
					}
				}
			}
			
			if searchType == .trie {
				HStack {
					TextField("", text: $searchTerm)
						.textFieldStyle(.roundedBorder)
						.border(.orange)
					Text("\(searchResults.count)")
						.modifier(numericTextCompat())
				}
			}
			
			if searchType == .contains {
				HStack {
					TextField("", text: $searchTerm)
						.textFieldStyle(.roundedBorder)
						.border(.orange)
					Text("\(searchResults.count)")
						.modifier(numericTextCompat())
				}
			}
				
			if uikit {
				EmojiCollectionView(hoarder: hoarder, items: searchResults)
					.animation(.snappy, value: searchResults)
			} else {
				List(searchResults, id: \.self) { item in
					EmojiRow(hoarder: hoarder, emoji: hoarder.trie.dict[item]!)
				}
				.animation(.snappy, value: searchResults)
			}
			
			Text("\(hoarder.trie.root.children.count)")
		}
		.padding(.horizontal)
	}
}

struct TrieNodeView: View {
	@ObservedObject var trie: Trie
	@State var trieNode: TrieNode
	
	var body: some View {
		ForEach(trieNode.children.map { $0.key }, id: \.self) { key in
			let node = trieNode.children[key]!
			Text(String(key))
				.foregroundStyle(node.isEndOfWord ? .red : .primary)
				.frame(width: 20, height: 20)
			TrieNodeView(trie: trie, trieNode: node)
				.padding(.leading, 20)
		}
	}
}

#Preview {
	TrieTestingView(hoarder: EmojiHoarder(localOnly: true))
}
