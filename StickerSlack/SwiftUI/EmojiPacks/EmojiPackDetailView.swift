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
	@State var searchTerm: String = ""
	
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
				ScrollView {
					Button() {
						editName.toggle()
					} label: {
						Text(pack.name.isEmpty ? "Name" : pack.name)
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
						Text(pack.description.isEmpty ? "Description" : pack.description)
							.foregroundStyle(edit ? .blue : .primary)
					}
					.disabled(!edit)
					.alert("Edit Description", isPresented: $editDescription) {
						TextField("", text: $pack.description)
					}
					
					if pack.items.isEmpty {
						VStack(alignment: .center) {
							HStack {
								Image(systemName: "exclamationmark.triangle.fill")
								Text("No Emoji")
									.bold()
								Image(systemName: "exclamationmark.triangle.fill")
							}
							.foregroundStyle(.yellow)
							Text("This pack contians no emojis")
								.padding(.vertical, 5)
								.foregroundStyle(.foreground)
							Text("Add emojis to this pack by editing it using the pencil button in the toolbar.")
							Text("You can also change the name and description by tapping it in edit mode.")
								.padding(.vertical, 5)
						}
						.foregroundStyle(.gray)
						.multilineTextAlignment(.center)
						.frame(maxWidth: .infinity)
						.padding()
						.background {
							Color.purple.opacity(0.2)
								.clipShape(RoundedRectangle(cornerRadius: 10))
								.blur(radius: 5)
								.shadow(color: .purple, radius: 5)
						}
						.padding()
					}
					
					let columns: Int = max(1, Int((geo.size.width - 2*spacing) / (minColWidth + spacing)))
					let layout = Array(repeating: col, count: columns)
					LazyVGrid(columns: layout, spacing: spacing) {
						ForEach(pack.items, id: \.self) { name in
							let emoji = hoarder.trie.dict[name] ?? .test
							VStack {
								StickerPreview(sticker: emoji)
								Spacer()
								Text(emoji.UIName)
									.multilineTextAlignment(.center)
									.font(.caption)
							}
							.overlay(alignment: .topLeading) {
								if edit {
									Button(role: .destructive) {
										pack.remove(name)
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
								NavigationStack {
									SearchView(hoarder: hoarder, fromPackEditor: true) { selection in
										pack.add(selection.name)
									}
									.navigationTitle("Search Emojis")
									.navigationBarTitleDisplayMode(.inline)
									.presentationDragIndicator(.visible)
									.presentationDetents([.large, .medium])
									.toolbar {
										Button("", systemImage: "xmark") {
											showAdder.toggle()
										}
									}
								}
							}
						}
					}
					.animation(.spring, value: pack.items)
					.padding()
					
					Text("\(pack.items.count) Emoji\(pack.items.count.plural)")
						.bold()
						.multilineTextAlignment(.center)
						.padding(.bottom)
				}
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
						ShareLink(item: pack.shareLink()) {
							Image(systemName: "square.and.arrow.up")
						}
					}
				}
				.onDisappear {
					hoarder.saveEmojiPacks()
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
