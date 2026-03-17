//
//  EmojiPreview.swift
//  StickerSlack
//
//  Created by neon443 on 19/10/2025.
//

import SwiftUI
import Haptics

struct StickerPreview: View {
	@State var emoji: any StickerProtocol
	
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
	StickerPreview(
		emoji: Emoji.test
	)
}
