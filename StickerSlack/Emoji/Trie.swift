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
	
	func insert(word: String) {
		let word = word.lowercased()
		var currentNode = root
		let indices = word.indices
		
		for i in indices {
			let char = word[i]
			if let node = currentNode.children[char] {
				print("node \(char) exists")
				currentNode = node
			} else {
				print("node \(char) didnt exist creating")
				currentNode.children[char] = TrieNode()
				currentNode = currentNode.children[char]!
				if i == indices.last {
					print("marking \(char) as end of word")
					currentNode.isEndOfWord = true
				}
			}
		}
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
}

struct TrieTestingView: View {
	@ObservedObject var trie: Trie = Trie()
	
	@State var id: UUID = UUID()
	
	@State var newWord: String = "hello"
	
	@State var searchTerm: String = ""
	@State var searchStatus: Bool? = nil
	
	var body: some View {
		VStack {
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
			
			Text("\(trie.root.children.count)")
			
			List {
				TrieNodeView(trieNode: trie.root)
			}
			.id(id)
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
