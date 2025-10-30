//
//  StickerSlackTests.swift
//  StickerSlackTests
//
//  Created by neon443 on 29/10/2025.
//

import Testing

struct StickerSlackTests {
	var hoarder = EmojiHoarder()
	
	@Test func stickerConversion() async throws {
		// Write your test here and use APIs like `#expect(...)` to check expected conditions.
		for emoji in hoarder.emojis {
			print(emoji.sticker)
		}
	}
	
	@Test func localImageURL() async throws {
		for emoji in hoarder.emojis {
			print(emoji.localImageURL)
		}
	}
	
	@Test func filteringEmojis() async throws {
		let searchQueries = ["heavysob", "yay", "afsdjk", "afhjskf", "g4", "aqua-osx", "neotunes", "", "", ""]
		for query in searchQueries {
			print(query)
			hoarder.filteredEmojis = []
			hoarder.filterEmojis(by: query)
			print(hoarder.filteredEmojis.count)
		}
	}
}
