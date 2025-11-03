//
//  Trie.swift
//  StickerSlack
//
//  Created by neon443 on 03/11/2025.
//

import Foundation
import SwiftUI
import Combine

class TrieNode: ObservableObject {
	@Published var children: [Character: TrieNode] = [:]
	@Published var isEndOfWord: Bool = false
}

class Trie: ObservableObject {
	@Published var root: TrieNode = TrieNode()
	@Published var allItems: [String] = []
	
	func insert(word: String) {
		let word = word.lowercased()
		var currentNode = root
		let indices = word.indices
		
		for i in indices {
			let char = word[i]
			if let node = currentNode.children[char] {
				currentNode = node
			} else {
				currentNode.children[char] = TrieNode()
				currentNode = currentNode.children[char]!
			}
			if i == indices.last {
				currentNode.isEndOfWord = true
			}
		}
		self.allItems.append(word)
	}
	
	func search(for query: String) -> Bool {
		var currentNode = root
		
		for char in query.lowercased() {
			if let node = currentNode.children[char] {
				currentNode = node
			} else {
				return false
			}
		}
		return currentNode.isEndOfWord
	}
	
	func search(prefix prefixQuery: String) -> [String] {
		guard !prefixQuery.isEmpty else { return allItems }
		let prefixQuery = prefixQuery.lowercased()
		var currentNode = root
		
		for char in prefixQuery {
			guard let child = currentNode.children[char] else {
				return []
			}
			currentNode = child
		}
		
		return collectWords(startingWith: prefixQuery, from: currentNode)
	}
	
	func collectWords(startingWith: String, from node: TrieNode) -> [String] {
		var results: [String] = []
		
		if node.isEndOfWord {
			results.append(startingWith)
		}
		for child in node.children {
			results += collectWords(startingWith: startingWith+String(child.key), from: child.value)
		}
		return results
	}
}

struct TrieTestingView: View {
	@ObservedObject var hoarder: EmojiHoarder = EmojiHoarder(localOnly: true)
	@ObservedObject var trie: Trie = Trie()
	
	@State var id: UUID = UUID()
	
	@State var newWord: String = "hello"
	
	@State var searchTerm: String = ""
	@State var searchStatus: Bool? = nil
	
	@State var filterTerm: String = ""
	@State var filterResult: [String] = []
	
	var body: some View {
		VStack {
			Button("add emojis!") {
				for name in hoarder.emojis.map({ $0.name }) {
					trie.insert(word: name)
				}
				print("done!")
			}
			.buttonStyle(.borderedProminent)
			
			TextField("", text: $newWord)
				.textFieldStyle(.roundedBorder)
				.border(.red)
			Button("add word") {
				trie.insert(word: newWord)
				id = UUID()
			}
			
			TextField("", text: $searchTerm)
				.textFieldStyle(.roundedBorder)
				.border(.orange)
				.onChange(of: searchTerm) { _ in
					searchStatus = trie.search(for: searchTerm)
				}
			if let searchStatus {
				Circle()
					.frame(width: 20, height: 20)
					.foregroundStyle(searchStatus ? .green : .red)
			}
			
			TextField("", text: $filterTerm)
				.textFieldStyle(.roundedBorder)
				.border(.orange)
				.onChange(of: filterTerm) { _ in
					filterResult = trie.search(prefix: filterTerm)
				}
			List(filterResult, id: \.self) { item in
				Text(item)
			}
//			.id(id)
			
			Text("\(trie.root.children.count)")
			
//			List {
//				TrieNodeView(trieNode: trie.root)
//			}
//			.id(id)
		}
	}
}

struct TrieNodeView: View {
	@State var trieNode: TrieNode
	
	var body: some View {
		ForEach(trieNode.children.map { $0.key }, id: \.self) { key in
			let node = trieNode.children[key]!
			Text(String(key))
				.foregroundStyle(node.isEndOfWord ? .red : .primary)
					.frame(width: 20, height: 20)
			TrieNodeView(trieNode: node)
				.padding(.leading, 20)
		}
	}
}

#Preview {
	TrieTestingView()
}
