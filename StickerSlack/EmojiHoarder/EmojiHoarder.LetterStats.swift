//
//  EmojiHoarder.LetterStats.swift
//  StickerSlack
//
//  Created by neon443 on 03/07/2026.
//

import Foundation

extension EmojiHoarder {
	func generateLetterStats() {
		var result: [EmojiHoarder.LetterStat] = []
		for child in trie.root.children {
			let count = trie.collectWords(startingWith: child.key, from: child.value).count
			let stat = LetterStat(char: child.key, count: count)
			result.append(stat)
		}
		self.letterStats = result
		sortLetterStats(by: self.letterStatsSorting)
	}
	
	func sortLetterStats(by: EmojiHoarder.LetterStatSorting) {
		self.letterStatsSorting = by
		let sortByLetter = letterStatsSorting.by == .letter
		switch by.ascending {
		case true:
			letterStats.sort {
				if sortByLetter {
					$0.char > $1.char
				} else {
					$0.count > $1.count
				}
			}
		case false:
			letterStats.sort {
				if sortByLetter {
					$0.char > $1.char
				} else {
					$0.count < $1.count
				}
			}
		}
	}
	
	struct LetterStat: Hashable {
		var char: String
		var count: Int
	}
	enum SortLetterStatsBy: String, CaseIterable {
		case letter = "Letter"
		case count = "Count"
	}
	struct LetterStatSorting: Hashable, Equatable {
		var by: EmojiHoarder.SortLetterStatsBy = .count
		var ascending: Bool = true
	}
}
