//
//  EmojiPackManager.swift
//  StickerSlack
//
//  Created by neon443 on 01/12/2025.
//

import SwiftUI

struct EmojiPackManager: View {
	@ObservedObject var hoarder: EmojiHoarder
	@State var useSwiftUIGrid: Bool = false
	@State var showShareSheet: Bool = false
	
	var body: some View {
		NavigationView2 {
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
						EmojiPackDetailView(hoarder: hoarder, pack: $pack, useSwiftUIGrid: useSwiftUIGrid)
					} label: {
						Text(pack.name)
					}
					.swipeActions(edge: .trailing) {
						if #available(iOS 16, *) {
							ShareLink(item: pack.shareLink())
						} else {
							Button {
								showShareSheet.toggle()
							} label: {
								Label("Share", systemImage: "square.and.arrow.up")
							}
							.sheet(isPresented: $showShareSheet) {
								ShareSheet(activityItems: [pack.shareLink()])
							}
						}
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
