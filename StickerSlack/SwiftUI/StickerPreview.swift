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
		} else if type(of: sticker) == Gif.self {
			let gif = sticker as! Gif
			if let giphyImages = gif.giphyImages,
			   let preview_gif = giphyImages.preview_gif,
			   let url = URL(string: preview_gif.url) {
				GifView(url: url)
			} else {
				GifView(url: gif.remoteImageURL)
					.overlay {
						Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
							.resizable().scaledToFit()
							.foregroundStyle(.red)
							.padding(1)
							.background(.black)
							.aspectRatio(1, contentMode: .fit)
							.padding()
					}
			}
		} else {
			Image(systemName: "xmark.app.fill")
				.resizable().scaledToFit()
				.foregroundStyle(.red)
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
	VStack {
		StickerPreview(
			sticker: Emoji.test
		)
		StickerPreview(
			sticker: Gif.test
		)
	}
}
