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
				ForEach($hoarder.emojiPacks) { $pack in
					NavigationLink {
						EmojiPackDetailView(hoarder: hoarder, pack: $pack)
					} label: {
						Text(pack.name)
					}
					.swipeActions(edge: .trailing) {
						Button {
							withAnimation {
								hoarder.emojiPacks.removeAll { $0.id == pack.id }
							}
						} label: {
							Label("Delete", systemImage: "trash")
						}
						.tint(.red)
					}
				}
				Spacer()
				NavigationLink {
					EmojiPackDetailView(hoarder: hoarder, pack: .constant(.test))
				} label: {
					Text("test")
				}
			}
			.navigationTitle("Emoji Packs")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem {
					Button {
						withAnimation {
							hoarder.emojiPacks.append(.new())
						}
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
