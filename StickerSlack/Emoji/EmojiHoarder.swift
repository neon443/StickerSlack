//
//  EmojiHoarder.swift
//  StickerSlack
//
//  Created by neon443 on 15/10/2025.
//

import Foundation
import SwiftUI
import Combine
import UniformTypeIdentifiers
import Haptics

@Observable class EmojiHoarder: BaseHoarder {
	static let container: URL = library.appendingPathComponent("Emojis", conformingTo: .directory)
	nonisolated static let localEmojiDB: URL = EmojiHoarder.library.appendingPathComponent("localEmojiDB.json", conformingTo: .fileURL)
	nonisolated static let localTrieDict: URL = EmojiHoarder.library.appendingPathComponent("localTrieDict.json", conformingTo: .fileURL)
	nonisolated static let packStore: URL = EmojiHoarder.library.appendingPathComponent("packStore.json", conformingTo: .fileURL)
	let endpoint: URL = URL(string: "https://cachet.dunkirk.sh/emojis")!
	
	var emojis: [Emoji] = []
	var emojiPacks: [EmojiPack] = []
	
	var trie: Trie = Trie()
	//	@Published var downloadedStickers: Set<String> = []
	var downloadedStickersArr: [String] = []
	
	var letterStats: [EmojiHoarder.LetterStat] = []
	var letterStatsSorting: EmojiHoarder.LetterStatSorting = .init(by: .letter, ascending: true)
	
	var showWelcome: Bool = false
	
	init(localOnly: Bool = false, skipIndex: Bool = false) {
		super.init()
		self.showWelcome = !UserDefaults.standard.bool(forKey: "showWelcome")
		
		if !FileManager.default.fileExists(atPath: EmojiHoarder.container.safePath) {
			try! FileManager.default.createDirectory(at: EmojiHoarder.container, withIntermediateDirectories: true)
		}
		
		loadEmojiPacks()
		
		self.emojis = loadLocalDB()
		self.trie.dict = loadTrieDict()
		
		startLoading(localOnly: localOnly, skipIndex: skipIndex)
	}
	
	func startLoading(localOnly: Bool, skipIndex: Bool) {
		Task.detached {
			print(localOnly)
			if !skipIndex { await self.buildTrie() }
			
			if !localOnly {
				print("start loading remote db")
				await self.loadRemoteDB()
				print("end")
			}
			
			if !skipIndex {
				await self.buildTrie()
				await self.saveTrieDict()
			}
		}
	}
	
	func downloadAllStickers() async {
		let start: Date = .now
		
//		let dict = trie.dict
//		let allStickers = Set(emojis.map { $0.name })
//		let downloadedStickers = downloadedStickers
//		let toDownload = allStickers.filter { !downloadedStickers.contains($0) }
//		
//		await withTaskGroup { group in
//			for name in toDownload {
//				group.addTask {
//					await self.download(emoji: dict[name], skipStoreIndex: true)
//				}
//			}
//		}
//		await buildDownloadedStickers()
		
		let cores = ProcessInfo.processInfo.processorCount-1
		var ranges: [Range<Int>] = []
		for i in 0..<cores {
			let onething = emojis.count/cores
			ranges.append(onething*i..<onething + (onething*i))
			if i == (0..<cores).last {
				let last = ranges.last!
				ranges.removeLast()
				ranges.append(onething*i..<(onething + (onething*i)+emojis.count-last.upperBound))
			}
		}
		
		await withTaskGroup { group in
			for range in ranges {
				group.addTask {
					for i in range {
						await self.download(emoji: self.emojis[i], skipStoreIndex: true)
					}
				}
			}
		}
		
		print(Date.now.timeIntervalSince(start))
	}
	
	func deleteAllStickers() async {
		await withTaskGroup { group in
			for i in emojis.indices {
				group.addTask {
					guard await self.downloadedStickers.contains(self.emojis[i].name) else { return }
					await self.delete(emoji: self.emojis[i], skipStoreIndex: true)
				}
			}
		}
		await MainActor.run {
			downloadedStickers = []
			downloadedStickersArr = []
		}
	}
	
	private func storeDB(data: Data) {
		try! data.write(to: EmojiHoarder.localEmojiDB)
	}
	
	func resetAllIndexes() {
		trie.root = TrieNode()
		trie.dict = [:]
		trie.wordlist = []
		try? FileManager.default.removeItem(at: EmojiHoarder.localEmojiDB)
		try? FileManager.default.removeItem(at: EmojiHoarder.localTrieDict)
		
		downloadedStickers = []
		letterStats = []
	}
	
	nonisolated private func saveTrieDict() async {
		guard let dataDict = try? await encoder.encode(trie.dict) else {
			fatalError("failed to encode trie dict")
		}
		try! dataDict.write(to: EmojiHoarder.localTrieDict)
	}
	
	private func loadTrieDict() -> [String: Emoji] {
		guard FileManager.default.fileExists(atPath: EmojiHoarder.localTrieDict.safePath) else { return [:] }
		guard let dataDict = try? Data(contentsOf: EmojiHoarder.localTrieDict) else { return [:] }
		guard let decodedDict = try? decoder.decode([String:Emoji].self, from: dataDict) else {
			fatalError("failed to decode dict")
		}
		return decodedDict
	}
	
	nonisolated
	func buildTrie() async {
		let start = Date().timeIntervalSince1970
		var wordlist = await trie.wordlist
		var dict = await trie.dict
		for emoji in await emojis {
			//			trie.insert(word: emoji.name)
			wordlist.insert(emoji.name)
			dict[emoji.name] = emoji
		}
		await trie.wordlist = wordlist
		await trie.dict = dict
		
		await buildDownloadedStickers()
		print("done building trie in", Date().timeIntervalSince1970-start)
	}
	
	nonisolated override func buildDownloadedStickers(for stickerType: String = "Emojis") async {
		await super.buildDownloadedStickers(for: stickerType)
		downloadedStickersArr = await Array(downloadedStickers).sorted()
	}

	private func loadLocalDB() -> [Emoji] {
		do {
			let localEmojiDB = try Data(contentsOf: EmojiHoarder.localEmojiDB)
			let decoded = try decoder.decode([Emoji].self, from: localEmojiDB)
			return decoded
		} catch {
			print(error)
			print(error.localizedDescription)
			return []
		}
	}
	
	nonisolated private func loadRemoteDB() async {
		async let fetched = self.fetchRemoteDB()
		if let fetched = await fetched,
		   await fetched != self.emojis {
			await MainActor.run {
				withAnimation(.snappy) { self.emojis = fetched }
			}
		}
	}
	
	nonisolated private func fetchRemoteDB() async -> [Emoji]? {
		do {
			async let (data, _) = try URLSession.shared.data(from: endpoint)
			let decoded: [SlackResponse] = try await decoder.decode([SlackResponse].self, from: await data)
			try await storeDB(data: await data)
			return await SlackResponse.toEmojis(from: decoded)
		} catch {
			print(error.localizedDescription)
			return nil
		}
	}
	
	nonisolated func batchDownload(emojis emojisToDownload: [any StickerProtocol]) async {
		await withTaskGroup { group in
			for emoji in emojisToDownload {
				group.addTask {
					await self.download(emoji: emoji, skipStoreIndex: true)
				}
			}
		}
		await buildDownloadedStickers()
	}
	
	override nonisolated func download(emoji: (any StickerProtocol)?, skipStoreIndex: Bool = false) async {
		guard let emoji else { return }
		guard await !downloadedStickers.contains(emoji.name) else { return }
		await super.download(emoji: emoji, skipStoreIndex: skipStoreIndex)
		
		await MainActor.run {
			if !skipStoreIndex {
				let _ = withAnimation(.snappy) {
					self.downloadedStickers.insert(emoji.name)
					self.downloadedStickersArr.append(emoji.name)
				}
			}
		}
	}
	
	nonisolated func batchDelete(emojis emojisToDelete: [any StickerProtocol]) async {
		await withTaskGroup { group in
			for emoji in emojisToDelete {
				group.addTask {
					await self.delete(emoji: emoji, skipStoreIndex: true)
				}
			}
		}
//		for emoji in emojisToDelete {
//			await delete(emoji: emoji, skipStoreIndex: true)
//		}
		await buildDownloadedStickers()
	}
	
	nonisolated override func delete(emoji: (any StickerProtocol)?, skipStoreIndex: Bool = false) async {
		guard let emoji else { return }
		await super.delete(emoji: emoji, skipStoreIndex: skipStoreIndex)
		
		if !skipStoreIndex {
			await MainActor.run {
				let _ = withAnimation(.snappy) {
					downloadedStickers.remove(emoji.name)
					downloadedStickersArr.removeAll(where: { $0 == emoji.name })
				}
			}
		}
	}
	
	func setShowWelcome(to newValue: Bool) {
		UserDefaults.standard.set(!newValue, forKey: "showWelcome")
		self.showWelcome = newValue
	}
	
	func loadEmojiPacks() {
		guard let data = try? Data(contentsOf: Self.packStore),
			  let decoded = try? decoder.decode([URL].self, from: data) else { return }
		self.emojiPacks = decoded.map {
			EmojiPack(fromShareLink: $0) ?? .new()
		}
	}
	
	func saveEmojiPacks() {
		var toStore: [URL] = []
		for pack in emojiPacks {
			toStore.append(pack.shareLink())
		}
		guard let encoded = try? encoder.encode(toStore) else { return }
		try? encoded.write(to: Self.packStore)
	}
	
	func newEmojiPack(withItems items: [String] = []) {
		addEmojiPack(.new(withItems: items))
	}
	
	func addEmojiPack(_ packToAdd: EmojiPack) {
		var packToAdd = packToAdd
		if emojiPacks.contains(where: { $0.id == packToAdd.id }) {
			packToAdd.id = UUID()
		}
		withAnimation {
			emojiPacks.append(packToAdd)
		}
		saveEmojiPacks()
	}
	
	func removeEmojiPack(_ packToRemove: EmojiPack) {
		withAnimation {
			emojiPacks.removeAll { $0.id == packToRemove.id }
		}
		saveEmojiPacks()
	}
	
	func removeEmojiPack(atOffsets offset: IndexSet) {
		withAnimation {
			emojiPacks.remove(atOffsets: offset)
		}
		saveEmojiPacks()
	}
	
	func moveEmojiPacks(fromOffsets: IndexSet, toOffset: Int) {
		withAnimation {
			emojiPacks.move(fromOffsets: fromOffsets, toOffset: toOffset)
		}
		saveEmojiPacks()
	}
	
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
