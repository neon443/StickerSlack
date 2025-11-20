//
//  EmojiPreview.swift
//  StickerSlack
//
//  Created by neon443 on 19/10/2025.
//

import SwiftUI
import Haptics

struct EmojiPreview: View {
	@ObservedObject var hoarder: EmojiHoarder
	@State var emoji: Emoji
	
	@State var gifImage: Image?

	var body: some View {
		if let image = emoji.image {
			GifView(url: emoji.localImageURL)
		} else {
			GifView(url: emoji.remoteImageURL)
		}
	}
}

struct ImageErrorView: View {
	var body: some View {
		Image(systemName: "xmark.app.fill")
			.resizable().scaledToFit()
			.padding()
			.symbolRenderingMode(.hierarchical)
			.foregroundStyle(.red)
	}
}

#Preview {
	EmojiPreview(
		hoarder: EmojiHoarder(localOnly: true),
		emoji: Emoji.test
	)
}
