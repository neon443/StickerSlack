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
	
	@Environment(\.editMode) var editMode
	@State var selection: Set<EmojiPack> = []
	
	@State var showDeleteAlert: Bool = false
	
	var body: some View {
		NavigationView2 {
			VStack {
				if hoarder.emojiPacks.isEmpty {
					EmptyCollectionView(
						title: "No Emoji Packs",
						details: "Create one using the button in the toolbar.",
						systemImage: "square.stack.3d.up.slash"
					)
					Spacer()
				} else {
					List(selection: $selection) {
						ForEach($hoarder.emojiPacks, id: \.self) { $pack in
							NavigationLink {
//								EmojiPackDetailView(hoarder: hoarder, pack: $pack, useSwiftUIGrid: useSwiftUIGrid)
								EmojiPackDetailViewRepresentable(hoarder: hoarder, pack: pack)
							} label: {
								Text(pack.name)
							}
							.swipeActions(edge: .trailing) {
								EmojiPackActionButtons(hoarder: hoarder, pack: pack, showLabelText: false)
							}
						}
						.onMove { indexSet, offset in
							hoarder.moveEmojiPacks(fromOffsets: indexSet, toOffset: offset)
						}
						.onDelete { indexSet in
							hoarder.removeEmojiPack(atOffsets: indexSet)
						}
					}
					.modifier(ContextMenuSafe(itemType: EmojiPack.self, menu: { items in
						if items.count == 1 {
							EmojiPackActionButtons(hoarder: hoarder, pack: items.first ?? .test, showLabelText: true)
						} else {
							Button("Delete \(items.count) pack\(items.count.plural)", systemImage: "trash", role: .destructive) {
								for item in items {
									hoarder.removeEmojiPack(item)
								}
							}
						}
					}))
				}
			}
			.navigationTitle("Emoji Packs")
			.navigationBarTitleDisplayMode(.inline)
			.animation(nil, value: editMode?.wrappedValue)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button("", systemImage: "plus") {
						hoarder.newEmojiPack()
					}
					.tint(.accentColor)
					.modifier(glassButtonIfAv())
				}
				ToolbarItem(placement: .topBarTrailing) {
					EditButton()
				}
			}
		}
	}
	
	struct EmojiPackActionButtons: View {
		@ObservedObject var hoarder: EmojiHoarder
		@State var pack: EmojiPack
		@State var showLabelText: Bool = true
		
		@State private var showShareSheet: Bool = false
		
		var body: some View {
			Button(showLabelText ? "Delete" : "", systemImage: "trash", role: .destructive) {
				hoarder.removeEmojiPack(pack)
			}
			.tint(.red)
			Button(showLabelText ? "Duplicate" : "", systemImage: "plus.square.fill.on.square.fill") {
				hoarder.addEmojiPack(pack)
			}
			if #available(iOS 16, *) {
				if showLabelText {
					ShareLink(item: pack.shareLink())
				} else {
					ShareLink(item: pack.shareLink())
						.labelStyle(.iconOnly)
				}
			} else {
				Button {
					showShareSheet.toggle()
				} label: {
					Label(showLabelText ? "Delete" : "", systemImage: "square.and.arrow.up")
				}
				.sheet(isPresented: $showShareSheet) {
					ShareSheet(activityItems: [pack.shareLink()])
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
