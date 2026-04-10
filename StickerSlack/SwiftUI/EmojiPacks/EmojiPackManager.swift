//
//  EmojiPackManager.swift
//  StickerSlack
//
//  Created by neon443 on 01/12/2025.
//

import SwiftUI

struct EmojiPackManager: View {
	@ObservedObject var hoarder: EmojiHoarder
	
	var body: some View {
		NavigationStack {
			List {
				if hoarder.emojiPacks.isEmpty {
					EmptyCollectionView(
						title: "No Emoji Packs",
						details: "Create one using the button in the toolbar.",
						systemImage: "square.stack.3d.up.slash"
					)
				}
				ForEach($hoarder.emojiPacks) { $pack in
					NavigationLink {
						EmojiPackDetailView(hoarder: hoarder, pack: $pack)
					} label: {
						Text(pack.name)
					}
					.swipeActions(edge: .trailing) {
						Button {
							hoarder.removeEmojiPack(pack)
						} label: {
							Label("Delete", systemImage: "trash")
						}
						.tint(.red)
					}
				}
			}
			.navigationTitle("Emoji Packs")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem {
					Button {
						hoarder.newEmojiPack()
					} label: {
						Image(systemName: "plus")
					}
					.tint(.accentColor)
					.modifier(glassButtonIfAv())
				}
			}
		}
	}
}

#Preview {
	EmojiPackManager(
		hoarder: EmojiHoarder(localOnly: true, skipIndex: true)
	)
}
