//
//  EmojiPackView.swift
//  StickerSlack
//
//  Created by neon443 on 01/12/2025.
//

import SwiftUI

struct EmojiPackDetailView: View {
	@ObservedObject var hoarder: EmojiHoarder
	@Binding var pack: EmojiPack
	@State var edit: Bool = false
	@State var editName: Bool = false
	@State var editDescription: Bool = false
	@State var showAdder: Bool = false
	
	var minColWidth: CGFloat { 75 }
	var spacing: CGFloat { 10 }
	var col: GridItem {
		GridItem(
			.flexible(minimum: minColWidth, maximum: 100),
			spacing: spacing,
			alignment: .center
		)
	}
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		NavigationStack {
			GeometryReader { geo in
				VStack {
					Button() {
						editName.toggle()
					} label: {
						Text(pack.name)
							.bold()
							.foregroundStyle(edit ? .blue : .primary)
							.font(.title)
					}
					.disabled(!edit)
					.alert("Edit Name", isPresented: $editName) {
						TextField("", text: $pack.name)
					}
					
					Button() {
						editDescription.toggle()
					} label: {
						Text(pack.description)
							.foregroundStyle(edit ? .blue : .primary)
					}
					.disabled(!edit)
					.alert("Edit Description", isPresented: $editDescription) {
						TextField("", text: $pack.description)
					}
					
					let columns: Int = max(1, Int((geo.size.width - 2*spacing) / (minColWidth + spacing)))
					let layout = Array(repeating: col, count: columns)
					LazyVGrid(columns: layout, spacing: spacing) {
						ForEach(pack.emojiNames, id: \.self) { name in
							let emoji = hoarder.trie.dict[name] ?? .test
							VStack {
								StickerPreview(sticker: emoji)
								Text(emoji.name)
									.multilineTextAlignment(.center)
									.font(.caption)
								Spacer()
							}
							.overlay(alignment: .topLeading) {
								if edit {
									Button(role: .destructive) {
										withAnimation {
											pack.emojiNames.removeAll { $0 == name }
										}
									} label: {
										Image(systemName: "minus.circle.fill")
											.resizable().scaledToFit()
									}
									.frame(maxWidth: 25)
									.padding(-10)
								}
							}
						}
						if edit {
							Button() {
								showAdder.toggle()
							} label: {
								VStack {
									Image(systemName: "plus.square.dashed")
										.resizable().scaledToFit()
										.foregroundStyle(.green.opacity(0.5))
									Text("Add")
										.multilineTextAlignment(.center)
										.font(.caption)
										.foregroundStyle(.green.opacity(0.5))
									Spacer()
								}
							}
							.sheet(isPresented: $showAdder) {
								SearchView(hoarder: hoarder, fromPackEditor: true) { selection in
									print(selection)
									withAnimation {
										pack.emojiNames.append(selection)
									}
								}
							}
						}
					}
					.padding(.vertical)
					
					Text("\(pack.emojiNames.count) Emoji\(pack.emojiNames.count.plural)")
						.bold()
						.multilineTextAlignment(.center)
				}
				.padding()
				.navigationTitle(edit ? "Editing" : "Pack Details")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem() {
						Button(
							"",
							systemImage: edit ? "checkmark" : "pencil"
						) {
							withAnimation { edit.toggle() }
						}
						.modifier(glassButtonIfAv(edit))
						.tint(edit ? .blue : .primary)
					}
					if #available(iOS 19, *) {
						ToolbarSpacer()
					}
					ToolbarItem() {
						ShareLink(item: URL(string: "stickerslack://")!) {
							Image(systemName: "square.and.arrow.up")
						}
					}
				}
				.onDisappear {
					print("disappear")
				}
			}
		}
	}
}

@available(iOS 17, *)
#Preview {
	@Previewable @State var pack: EmojiPack = .test
	EmojiPackDetailView(
		hoarder: EmojiHoarder(localOnly: true, skipIndex: false),
		pack: $pack
	)
}
