//
//  EmojiHoarder.Packs.swift
//  StickerSlack
//
//  Created by neon443 on 03/07/2026.
//

import Foundation
import SwiftUI

extension EmojiHoarder {
	func loadEmojiPacks() {
		guard let data = try? Data(contentsOf: Self.packStore),
			  let decoded = try? decoder.decode([URL].self, from: data) else { return }
		self.emojiPacks = decoded.map {
			EmojiPack(fromShareLink: $0) ?? .new()
		}
		sendChangeNotif(for: .emojiPacks)
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
		sendChangeNotif(for: .emojiPacks)
	}
	
	func addEmojiPack(_ packToAdd: EmojiPack) {
		var packToAdd = packToAdd
		if emojiPacks.contains(where: { $0.id == packToAdd.id }) {
			packToAdd.id = UUID()
		}
		withAnimation {
			emojiPacks.append(packToAdd)
		}
		sendChangeNotif(for: .emojiPacks)
		saveEmojiPacks()
	}
	
	func removeEmojiPack(_ packToRemove: EmojiPack) {
		withAnimation {
			emojiPacks.removeAll { $0.id == packToRemove.id }
		}
		sendChangeNotif(for: .emojiPack(packToRemove))
		sendChangeNotif(for: .emojiPacks)
		saveEmojiPacks()
	}
	
	func removeEmojiPack(atOffsets offset: IndexSet) {
		withAnimation {
			emojiPacks.remove(atOffsets: offset)
		}
		sendChangeNotif(for: .emojiPacks)
		saveEmojiPacks()
	}
	
	func moveEmojiPacks(fromOffsets: IndexSet, toOffset: Int) {
		withAnimation {
			emojiPacks.move(fromOffsets: fromOffsets, toOffset: toOffset)
		}
		sendChangeNotif(for: .emojiPacks)
		saveEmojiPacks()
	}
}
