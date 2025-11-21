//
//  TrieTestingView.swift
//  StickerSlack
//
//  Created by neon443 on 03/11/2025.
//

import SwiftUI

struct TrieTestingView: View {
	@ObservedObject var hoarder: EmojiHoarder 
	
	@State var searchTerm: String = ""
	@State var searchStatus: Bool? = nil
	
	@State var filterTerm: String = ""
	@State var filterResult: [String] = []
	
	@State var filterTerm2: String = ""
	
	@State var uikit: Bool = false
	
	var body: some View {
		VStack {
			Toggle("uikit!!", isOn: $uikit)
				.foregroundStyle(.blue)
			
			Button("reset", role: .destructive) {
				hoarder.resetTrie()
			}
			Button("add emojis!") {
				hoarder.buildTrie()
			}
			.buttonStyle(.borderedProminent)
			
			HStack {
				TextField("", text: $searchTerm)
					.textFieldStyle(.roundedBorder)
					.border(.orange)
					.onChange(of: searchTerm) { _ in
						searchStatus = hoarder.trie.search(for: searchTerm)
					}
				if let searchStatus {
					Circle()
						.frame(width: 20, height: 20)
						.foregroundStyle(searchStatus ? .green : .red)
				} else {
					Text("?")
						.frame(width: 20, height: 20)
				}
			}
			
			HStack {
				TextField("", text: $filterTerm)
					.textFieldStyle(.roundedBorder)
					.border(.orange)
					.onChange(of: filterTerm) { _ in
						withAnimation { filterResult = hoarder.trie.search(prefix: filterTerm) }
					}
				Text("\(filterResult.count)")
					.modifier(numericTextCompat())
			}
			
			TextField("", text: $filterTerm2)
				.textFieldStyle(.roundedBorder)
				.border(.orange)
				.onChange(of: filterTerm2) { _ in
					withAnimation { filterResult = hoarder.emojis.filter({ $0.name.localizedCaseInsensitiveContains(filterTerm2) }).map({ $0.name }) }
				}
				
			if uikit {
				EmojiCollectionView(hoarder: hoarder, items: filterResult)
					.id(filterResult)
			} else {
				List(filterResult, id: \.self) { item in
					EmojiRow(hoarder: hoarder, emoji: hoarder.trie.dict[item]!)
				}
			}
			
			Text("\(hoarder.trie.root.children.count)")
		}
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
