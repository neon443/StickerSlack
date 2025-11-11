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
	@Published var dict: [String:Emoji] = [:]
	
	func insert(word: String) {
		let word = word.lowercased()
		var currentNode = root
		let indices = word.indices
		let last = indices.last
		
		for i in indices {
			let char = word[i]
			if let node = currentNode.children[char] {
				currentNode = node
			} else {
				currentNode.children[char] = TrieNode()
				currentNode = currentNode.children[char]!
			}
			if i == last {
				currentNode.isEndOfWord = true
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
	
	func search(prefix prefixQuery: String) -> [String] {
		guard !prefixQuery.isEmpty else { return [] }
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
