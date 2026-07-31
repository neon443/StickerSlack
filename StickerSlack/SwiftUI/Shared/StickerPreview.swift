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
		if sticker.isLocal {
			//local
			GifView(url: sticker.localImageURL)
		} else {
			//remote
			GifView(url: sticker.remoteImageURL)
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
	}
}
