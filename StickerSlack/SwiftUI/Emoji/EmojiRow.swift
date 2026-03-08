//
//  EmojiRow.swift
//  StickerSlack
//
//  Created by neon443 on 03/11/2025.
//

import SwiftUI
import Haptics

struct EmojiRow: View {
	@ObservedObject var hoarder: EmojiHoarder
	@State var emoji: Emoji

	var body: some View {
		HStack {
			EmojiPreview(hoarder: hoarder, emoji: emoji)
			.frame(width: 100, height: 100)
			.padding(.trailing, 10)
			
			VStack(alignment: .leading, spacing: 5) {
				ZStack {
					RoundedRectangle(cornerRadius: 5)
						.foregroundStyle(.gray.opacity(0.1))
					Text(emoji.name)
						.font(.caption)
						.bold(hoarder.downloadedEmojis.contains(emoji.name))
						.foregroundColor(hoarder.downloadedEmojis.contains(emoji.name) ? .green : .primary)
						.padding(3)
				}
				.fixedSize()
				if hoarder.downloadedEmojis.contains(emoji.name) {
					Image(systemName: "arrow.down.circle.fill")
						.resizable().scaledToFit()
						.frame(width: 20, height: 20)
						.symbolRenderingMode(.hierarchical)
						.foregroundStyle(.gray)
						.transition(.scale)
				}
			}
			
			Spacer()
			
			if hoarder.downloadedEmojis.contains(emoji.name) {
				Button("", systemImage: "trash") {
					hoarder.delete(emoji: emoji)
				}
				.buttonStyle(.plain)
				.transition(.scale)
			} else {
				Button("", systemImage: "arrow.down.circle") {
					Task {
						await hoarder.download(emoji: emoji)
					}
				}
				.buttonStyle(.plain)
				.transition(.scale)
			}
		}
    }
}

#Preview {
	List {
		EmojiRow(
			hoarder: EmojiHoarder(localOnly: true),
			emoji: Emoji.test
		)
		EmojiRow(
			hoarder: EmojiHoarder(localOnly: true),
			emoji: Emoji.test
		)
	}
}
