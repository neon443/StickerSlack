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
		let goodEmoji = Emoji(apiEmoji: ApiEmoji(name: "name", url: "https://neon443.github.io/images/fav.ico"), id: UUID(uuidString: "0c48f4c3-1c63-41ed-96db-909e50e35dfc")!)
		let _ = try! await goodEmoji.downloadImage()
		#expect(goodEmoji.sticker!.validate(), "should be true")
		
		let badEmoji = Emoji(apiEmoji: ApiEmoji(name: "160chars:shttps://emoji.slack-edge.com/T0266FRGM/100906/ddeb22d813b83b0f.pngs,sexpirationfds2025-10-28T08:00:02.011Zs},{gtypeh:jemojieeeidggg9cab2003-ad74-492a-", url: "https://files.catbox.moe/ifh710.png"), id: UUID(uuidString: "0c48f4c3-1c63-41ed-96db-909e50e35dfc")!)
		let _ = try! await badEmoji.downloadImage()
		#expect(goodEmoji.sticker!.validate(), "should be true")
		badEmoji.deleteImage()
	}
	
	@Test func deleteAllEmojis() async throws {
		await withDiscardingTaskGroup { group in
			for emoji in hoarder.emojis {
				group.addTask {
					emoji.deleteImage()
				}
			}
		}
	}
}

struct PerformanceTests {
	var hoarder = EmojiHoarder()
	
	@Test func stickerConversion() async throws {
		// Write your test here and use APIs like `#expect(...)` to check expected conditions.
		for emoji in hoarder.emojis {
			let _ = emoji.sticker
		}
	}
	
	@Test func localImageURL() async throws {
		for emoji in hoarder.emojis {
			let _ = emoji.localImageURL
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
	
	@Test func MSStickerValidation() async throws {
		let undownloadedEmojisBefore = hoarder.emojis.filter { !$0.isLocal }.map { $0.id }
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
	
	func doThing(on emoji: Emoji, i: inout Int) async throws {
		do {
			guard !emoji.isLocal else { return }
			async let (data, _) = try URLSession.shared.data(from: emoji.remoteImageURL)
			try! await data.write(to: emoji.localImageURL)
			let _ = emoji.sticker?.validate()
			i+=1
			print("\(i)/\(hoarder.emojis.count) \(emoji.name)")
		} catch {
			try! await doThing(on: emoji, i: &i)
		}
	}
}
