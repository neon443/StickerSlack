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
		if sticker.image != nil {
			//local
			GifView(url: sticker.localImageURL)
		} else {
			//remote
			if sticker.type == .slackEmoji {
				GifView(url: sticker.remoteImageURL)
			} else {
				let gif = sticker as! Gif
				if let giphyImages = gif.giphyImages,
				   let preview_gif = giphyImages.preview_gif,
				   let url = URL(string: preview_gif.url) {
					GifView(url: url)
				} else {
					GifView(url: gif.remoteImageURL)
						.overlay {
							Image(systemName:
									"square.arrowtriangle.4.outward")
							.resizable().scaledToFit()
							.foregroundStyle(.red)
							.background(.black)
							.padding()
						}
				}
			}
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
