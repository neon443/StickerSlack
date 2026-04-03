//
//  EmojiPreview.swift
//  StickerSlack
//
//  Created by neon443 on 19/10/2025.
//

import SwiftUI
import Haptics

struct StickerPreview: View {
	@State var sticker: any StickerProtocol
	
	@State var gifImage: Image?

	var body: some View {
		if type(of: sticker) == Emoji.self {
			if sticker.image != nil {
				GifView(url: sticker.localImageURL)
			} else {
				GifView(url: sticker.remoteImageURL)
			}
		} else {
			GifView(url: URL(string: (sticker as! Gif).giphyImages!.preview_gif!.url)!)
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
		sticker: Emoji.test
	)
}
