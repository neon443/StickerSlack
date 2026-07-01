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
								EmojiPackDetailView(hoarder: hoarder, pack: $pack, useSwiftUIGrid: useSwiftUIGrid)
							} label: {
								Text(pack.name)
							}
							.contextMenu {
								EmojiPackActionButtons(hoarder: hoarder, pack: pack, showLabelText: true)
							} preview: {
								EmojiPackPreview(hoarder: hoarder, pack: pack)
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
				}
			}
			.navigationTitle("Emoji Packs")
			.navigationBarTitleDisplayMode(.inline)
			.animation(nil, value: editMode?.wrappedValue)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button("", systemImage: "plus") {
						hoarder.newEmojiPack()
					}
					.tint(.accentColor)
					.modifier(glassButtonIfAv())
				}
				ToolbarItem(placement: .topBarLeading) {
					EditButton()
				}
				
				if #available(iOS 19, *) {
					ToolbarSpacer()
				}
				
//				if editMode?.wrappedValue.isEditing ?? false {
					ToolbarItem(placement: .topBarLeading) {
						Button("", systemImage: "trash") {
							showDeleteAlert.toggle()
						}
						.disabled(selection.isEmpty)
						.confirmationDialog("These items will be deleted immediately", isPresented: $showDeleteAlert) {
							Button("Delete \(selection.count) pack\(selection.count.plural)", role: .destructive) {
								for pack in selection {
									hoarder.removeEmojiPack(pack)
								}
							}
						} message: {
							Text("This action cannot be undone")
						}
					}
//				}
			}
		}
	}
	
	struct EmojiPackActionButtons: View {
		@ObservedObject var hoarder: EmojiHoarder
		@State var pack: EmojiPack
		@State var showLabelText: Bool = true
		
		@State private var showShareSheet: Bool = false
		
		var body: some View {
			Button {
				hoarder.removeEmojiPack(pack)
			} label: {
				Label(showLabelText ? "Delete" : "", systemImage: "trash")
					.foregroundStyle(.red)
			}
			.tint(.red)
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
