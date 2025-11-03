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
		var currentNode = root
		for char in word {
			if let node = currentNode.children[char] {
				print("node \(char) exists")
				currentNode = node
			} else {
				print("node \(char) didnt exist creating")
				currentNode.children[char] = TrieNode()
				currentNode = currentNode.children[char]!
			}
		}
	}
}

struct TrieTestingView: View {
	@ObservedObject var trie: Trie = Trie()
	@State var id: UUID = UUID()
	@State var newWord: String = ""
	@State var searchTerm: String = ""
	
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
			Text(String(key))
					.frame(width: 20, height: 20)
			TrieNodeView(trieNode: trieNode.children[key]!)
				.padding(.leading, 20)
		}
	}
}

#Preview {
	TrieTestingView()
}
