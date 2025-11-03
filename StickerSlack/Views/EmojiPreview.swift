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
	
	@State private var id: UUID = UUID()
	@State private var delay: TimeInterval = 0
	
    var body: some View {
		VStack(alignment: .leading) {
			Text(emoji.name)
			Group {
				if let image = emoji.image {
					Image(uiImage: image)
						.resizable().scaledToFit()
						.border(.orange)
						.overlay(alignment: .bottomLeading) {
							Image(systemName: "arrow.down.circle.fill")
								.foregroundStyle(.gray)
								.shadow(radius: 1)
								.symbolRenderingMode(.hierarchical)
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
}

#Preview {
	EmojiPreview(
		hoarder: EmojiHoarder(localOnly: true),
		emoji: Emoji(
			name: "s?",
			url: URL(string: "https://neon443.github.io/images/fav.ico")!
		)
	)
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
