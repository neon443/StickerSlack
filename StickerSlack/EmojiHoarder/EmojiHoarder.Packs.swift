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
	
	func updateEmojiPack(_ updatedPack: EmojiPack) {
		guard let index = self.emojiPacks.firstIndex(where: { $0.id == updatedPack.id }) else { return }
		withAnimation {
			self.emojiPacks[index] = updatedPack
		}
		saveEmojiPacks()
	}
	
	func moveEmojiPacks(fromOffsets: IndexSet, toOffset: Int) {
		withAnimation {
			emojiPacks.move(fromOffsets: fromOffsets, toOffset: toOffset)
		}
		saveEmojiPacks()
	}
}
