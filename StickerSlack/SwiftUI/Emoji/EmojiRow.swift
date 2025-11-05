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
			EmojiPreview(
				hoarder: hoarder,
				emoji: emoji
			)
			.frame(maxWidth: 100, maxHeight: 100)
			Spacer()
			if hoarder.downloadedEmojis.contains(emoji.name) {
				Button("", systemImage: "trash") {
					emoji.deleteImage()
					emoji.refresh()
					Haptic.heavy.trigger()
				}
				.buttonStyle(.plain)
			} else {
				Button("", systemImage: "arrow.down.circle") {
					Task.detached {
						try? await emoji.downloadImage()
						await MainActor.run {
							emoji.refresh()
							Haptic.success.trigger()
						}
					}
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
