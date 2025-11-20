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
	@State var stopPointer: UnsafeMutablePointer<Bool>?
	
	@State private var id: UUID = UUID()
	@State private var delay: TimeInterval = 0
	
	var body: some View {
		Group {
			if let image = emoji.image {
				if emoji.localImageURLString.contains(".gif") {
					GifView(url: emoji.localImageURL)
				} else {
					Image(uiImage: image)
						.resizable().scaledToFit()
				}
			} else {
				AsyncImage(url: emoji.remoteImageURL) { phase in
					if let image = phase.image {
						image
							.resizable().scaledToFit()
					} else if phase.error != nil {
						ImageErrorView()
							.onTapGesture {
								id = UUID()
							}
							.onAppear {
								DispatchQueue.main.asyncAfter(deadline: .now()+delay) {
									id = UUID()
									delay+=0.1
								}
							}
					} else {
						ProgressView()
							.frame(maxWidth: .infinity, maxHeight: .infinity)
					}
				}
			}
		}
		.id(id)
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
