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
			VStack {
				HStack(spacing: .zero) {
//					Text
					Text(emoji.name)
				}
				EmojiPreview(
					hoarder: hoarder,
					emoji: emoji
				)
			}
			.frame(maxWidth: 100, maxHeight: 100)
			Spacer()
			if hoarder.downloadedEmojis.contains(emoji.name) {
				Button("", systemImage: "trash") {
					hoarder.delete(emoji: emoji)
				}
				.buttonStyle(.plain)
			} else {
				Button("", systemImage: "arrow.down.circle") {
					hoarder.download(emoji: emoji)
				}
				.buttonStyle(.plain)
			}
		}
    }
}

#Preview {
	EmojiRow(
		hoarder: EmojiHoarder(localOnly: true),
		emoji: Emoji.test
	)
}
