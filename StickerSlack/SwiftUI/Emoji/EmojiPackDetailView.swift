//
//  EmojiPackView.swift
//  StickerSlack
//
//  Created by neon443 on 01/12/2025.
//

import SwiftUI

struct EmojiPackDetailView: View {
	@ObservedObject var hoarder: EmojiHoarder
	@State var pack: EmojiPack
	@State var edit: Bool = true
	
	var minColWidth: CGFloat { 75 }
	var spacing: CGFloat { 10 }
	var col: GridItem {
		GridItem(
			.flexible(minimum: minColWidth, maximum: 100),
			spacing: spacing,
			alignment: .center
		)
	}
	var body: some View {
		NavigationStack {
			GeometryReader { geo in
				VStack {
					if #unavailable(iOS 19) {
						Button() {
							
						} label: {
							Text(pack.name)
								.bold()
								.foregroundStyle(edit ? .blue : .primary)
								.font(.title)
						}
						.disabled(!edit)
					}
					Button() {
						
					} label: {
						Text(pack.description)
							.foregroundStyle(edit ? .blue : .primary)
					}
					.disabled(!edit)
					
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
							}
						}
					}
					.padding(.vertical)
					
					Text("\(pack.emojiNames.count) Emoji\(pack.emojiNames.count.plural)")
						.bold()
						.multilineTextAlignment(.center)
				}
				.padding()
				.navigationTitle(edit ? "Editing" : pack.name)
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
			}
		}
	}
}

#Preview {
	EmojiPackDetailView(
		hoarder: EmojiHoarder(localOnly: true, skipIndex: true),
		pack: .test
	)
}
