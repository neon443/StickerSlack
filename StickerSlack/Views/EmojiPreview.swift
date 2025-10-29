//
//  EmojiPreview.swift
//  StickerSlack
//
//  Created by neon443 on 19/10/2025.
//

import SwiftUI
import Haptics

struct EmojiPreview: View {
	@State var emoji: Emoji
	
	@State private var id: UUID = UUID()
	
    var body: some View {
		VStack(alignment: .leading) {
			Text(emoji.name)
			Group {
				if let localImage = try? Data(contentsOf: emoji.localImageURL),
				   let image = UIImage(data: localImage) {
					Image(uiImage: image)
						.resizable().scaledToFit()
						.border(.orange)
						.overlay(alignment: .bottomLeading) {
							Image(systemName: "arrow.down.circle.fill")
								.resizable().scaledToFit()
								.frame(width: 20, height: 20)
								.symbolRenderingMode(.hierarchical)
								.shadow(radius: 1)
						}
				} else {
					AsyncImage(url: emoji.remoteImageURL) { phase in
						if let image = phase.image {
							image
								.resizable().scaledToFit()
						} else if phase.error != nil {
							ZStack {
								Image(systemName: "xmark.app.fill")
									.resizable().scaledToFit()
									.padding()
									.padding()
									.symbolRenderingMode(.hierarchical)
									.foregroundStyle(.red)
									.onAppear {
										id = UUID()
									}
									.onTapGesture {
										id = UUID()
									}
							}
						} else {
							ProgressView()
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
		emoji: ApiEmoji(
			name: "s?",
			url: "https://neon443.github.io/images/fav.ico"
		).toEmoji()
	)
}
