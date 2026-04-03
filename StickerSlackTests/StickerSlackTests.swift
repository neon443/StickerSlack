//
//  StickerSlackTests.swift
//  StickerSlackTests
//
//  Created by neon443 on 29/10/2025.
//

import Testing
import Foundation

struct StickerSlackTests {
	var hoarder = EmojiHoarder()
	
	@Test func MSStickerValidation() async throws {
		let goodEmoji = Emoji(
			name: "name",
			url: URL(string: "https://neon443.xyz/images/fav.ico")!,
			id: "0c48f4c3-1c63-41ed-96db-909e50e35dfc"
		)
		try! await goodEmoji.downloadImage()
		#expect(goodEmoji.msSticker!.validate(), "should be true")
		
		let badEmoji = Emoji(
			name: "160chars:shttps://emoji.slack-edge.com/T0266FRGM/100906/ddeb22d813b83b0f.pngs,sexpirationfds2025-10-28T08:00:02.011Zs},{gtypeh:jemojieeeidggg9cab2003-ad74-492a-",
			url: URL(string: "https://files.catbox.moe/ifh710.png")!,
			id: "0c48f4c3-1c63-41ed-96db-909e50e35dfc"
		)
		try! await badEmoji.downloadImage()
		#expect(goodEmoji.msSticker!.validate(), "should be true")
		badEmoji.deleteImage()
	}
}

struct PerformanceTests {
	var hoarder = EmojiHoarder()
	
	@Test func stickerConversion() async throws {
		// Write your test here and use APIs like `#expect(...)` to check expected conditions.
		for emoji in hoarder.emojis {
			let _ = emoji.msSticker
		}
	}
	
	@Test func localImageURL() async throws {
		for emoji in hoarder.emojis {
			let _ = emoji.localImageURL
		}
	}
	
	/*
	@Test func downloadAll() async throws {
		let downloadedEmojisBefore = hoarder.emojis.filter { $0.isLocal }.map { $0.id }
		
		try? await withThrowingDiscardingTaskGroup { group in
			var i = 0
			let maxTasks = ProcessInfo.processInfo.processorCount-1
			var activeTasks = 0
			
			for emoji in hoarder.emojis {
				if activeTasks >= maxTasks {
					let ib4 = i
					while i <= ib4 {
						try? await Task.sleep(nanoseconds: 1)
					}
					activeTasks -= 1
				}
				group.addTask {
					try? await doThing(on: emoji, i: &i)
					activeTasks -= 1
				}
				activeTasks += 1
			}
		}
		
		await withDiscardingTaskGroup { group in
			var i = 0
			for emoji in hoarder.emojis {
				emoji.deleteImage()
				guard downloadedEmojisBefore.contains(emoji.id) else { continue }
				async let (data, _) = try! URLSession.shared.data(from: emoji.remoteImageURL)
				try! await data.write(to: emoji.localImageURL)
				i+=1
				print("\(i)/\(downloadedEmojisBefore.count) \(emoji.name)")
			}
		}
	}
	*/
	
	func doThing(on emoji: Emoji, i: inout Int) async throws {
		do {
			guard !emoji.isLocal else { return }
			async let (data, _) = try URLSession.shared.data(from: emoji.remoteImageURL)
			try! await data.write(to: emoji.localImageURL)
			let _ = emoji.msSticker?.validate()
			i+=1
			print("\(i)/\(hoarder.emojis.count) \(emoji.name)")
		} catch {
			try! await doThing(on: emoji, i: &i)
		}
	}
	
//	@Test func fakeDownloadAllStickers() async throws {
//		await withDiscardingTaskGroup { group in
//			for emoji in hoarder.emojis {
//				group.addTask {
//					try! Data().write(to: emoji.localImageURL)
//				}
//			}
//		}
//	}
	
	@Test func deleteAllImages() async throws {
//		try! await fakeDownloadAllStickers()
		await hoarder.deleteAllStickers()
	}
	
	@Test func buildTrie() async throws {
		hoarder.resetAllIndexes()
		hoarder.buildTrie()
	}
	
	@Test func testIsLocal() async throws {
		for emoji in hoarder.emojis {
			let x = emoji.isLocal
		}
	}
	
	@Test func testDownloadedEmojis() async throws {
		for emoji in hoarder.emojis {
			let x = hoarder.downloadedStickers.contains(emoji.name)
		}
	}
	
	@Test func testSearching() async throws {
		try await testSearchingExactly()
		try await testSearchingFor()
		try await testSearchingPrefixes()
	}
	@Test func testSearchingFor() async throws {
		let queries = hoarder.emojis.choose(10_000).map { $0.name }
		for query in queries {
			let _ = hoarder.trie.search(for: query, previousQuery: nil, previousResult: nil)
		}
	}
	@Test func testSearchingExactly() async throws {
		let queries = hoarder.emojis.choose(10_000).map { $0.name }
		for query in queries {
			let _ = hoarder.trie.search(exactly: query)
		}
	}
	@Test func testSearchingPrefixes() async throws {
		let queries = hoarder.emojis.choose(10_000).map { $0.name }
		for query in queries {
			let _ = hoarder.trie.search(prefix: query)
		}
	}
}

extension Array {
	func choose(_ x: Int) -> Self {
		var x = x
		var result: Self = []
		while x != 0 {
			guard let randElement = self.randomElement() else { continue }
			result.append(randElement)
			x-=1
		}
		return result
	}
}
