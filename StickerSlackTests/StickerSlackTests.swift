//
//  StickerSlackTests.swift
//  StickerSlackTests
//
//  Created by neon443 on 29/10/2025.
//

import Testing

struct StickerSlackTests {
	var hoarder = EmojiHoarder()
	
	@Test func example() async throws {
		// Write your test here and use APIs like `#expect(...)` to check expected conditions.
		for emoji in hoarder.emojis {
			print(emoji.sticker)
		}
	}
	
}
