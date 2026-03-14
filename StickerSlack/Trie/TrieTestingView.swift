//
//  TrieTestingView.swift
//  StickerSlack
//
//  Created by neon443 on 03/11/2025.
//

import SwiftUI

struct TrieTestingView: View {
	@ObservedObject var hoarder: EmojiHoarder 
	
	@State var searchStatus: Bool? = nil
	
	@State var filterTerm: String = ""
	@State var filterResult: [String] = []
	
	@State var uikit: Bool = false
	
	@State private var searchType: SearchType = .contains
	private enum SearchType: String, CaseIterable {
		case trie = "trie"
		case contains = "contains"
		case exact = "exact"
	}
	
	private func runSearch() {
		filterResult = []
		searchStatus = nil
		guard !filterTerm.isEmpty else { return }
		switch searchType {
		case .trie:
			withAnimation(.snappy) {
				filterResult = hoarder.trie.search(prefix: filterTerm)
			}
			print("testing: trie search")
		case .contains:
			Task.detached {
				var results: [[Emoji]] = []
				var result: [Emoji] = []
				for word in filterTerm.split(separator: " ") {
					results.append(hoarder.emojis.filter({ $0.name.localizedCaseInsensitiveContains(word) }))
				}
				result = results.reduce(results[0]) { partialResult, array in
					partialResult.filter { array.contains($0) }
				}
				await MainActor.run {
					withAnimation(.snappy) {
						filterResult = result.map { $0.name }
					}
					print("testing: contains search")
				}
			}
		case .exact:
			withAnimation(.snappy) {
				searchStatus = hoarder.trie.search(for: filterTerm)
			}
			print("testing: exact search")
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
			.onChange(of: searchType.rawValue+filterTerm) { _ in
				runSearch()
			}

			if searchType == .exact {
				HStack {
					TextField("", text: $filterTerm)
						.textFieldStyle(.roundedBorder)
						.border(.orange)
					if let searchStatus {
						Circle()
							.frame(width: 20, height: 20)
							.foregroundStyle(searchStatus ? .green : .red)
					} else {
						Text("?")
							.frame(width: 20, height: 20)
					}
				}
			}
			
			if searchType == .trie {
				HStack {
					TextField("", text: $filterTerm)
						.textFieldStyle(.roundedBorder)
						.border(.orange)
					Text("\(filterResult.count)")
						.modifier(numericTextCompat())
				}
			}
			
			if searchType == .contains {
				HStack {
					TextField("", text: $filterTerm)
						.textFieldStyle(.roundedBorder)
						.border(.orange)
					Text("\(filterResult.count)")
						.modifier(numericTextCompat())
				}
			}
				
			if uikit {
				EmojiCollectionView(hoarder: hoarder, items: filterResult)
					.animation(.snappy, value: filterResult)
			} else {
				List(filterResult, id: \.self) { item in
					EmojiRow(hoarder: hoarder, emoji: hoarder.trie.dict[item]!)
				}
				.animation(.snappy, value: filterResult)
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
