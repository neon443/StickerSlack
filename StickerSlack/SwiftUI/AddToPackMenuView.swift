//
//  AddToPackMenuView.swift
//  StickerSlack
//
//  Created by neon443 on 01/05/2026.
//

import SwiftUI

struct AddToPackMenuView: View {
	@ObservedObject var emojiHoarder: EmojiHoarder
	@State var sticker: Emoji
	
	var body: some View {
		Menu {
			if emojiHoarder.emojiPacks.isEmpty {
				Label("No Packs", systemImage: "questionmark.app.dashed")
			} else {
				Label("Add to Pack", systemImage: "square.stack.3d.up.fill")
			}
			ForEach($emojiHoarder.emojiPacks) { $pack in
				Button() {
					pack.addRemove(sticker.name)
					emojiHoarder.saveEmojiPacks()
				} label: {
					if pack.items.contains(sticker.name) {
						Image(systemName: "checkmark")
					}
					Text(pack.name)
					Text("\(pack.items.count) item"+pack.items.count.plural)
				}
			}
			Divider()
			Button("Create New", systemImage: "plus") {
				emojiHoarder.newEmojiPack(withItems: [sticker.name])
			}
		} label: {
			Image(systemName: "plus")
				.resizable().scaledToFit()
		}
	}
}

#Preview {
	AddToPackMenuView(
		emojiHoarder: EmojiHoarder(localOnly: true, skipIndex: true),
		sticker: .test
	)
}
