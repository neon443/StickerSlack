//
//  EmojiPreview.swift
//  StickerSlack
//
//  Created by neon443 on 19/10/2025.
//

import SwiftUI

struct EmojiPreview: View {
	@State var emoji: Emoji
	
	@State private var id: UUID = UUID()
	
    var body: some View {
		VStack {
			Text(emoji.name)
			if let image = emoji.image {
				Image(uiImage: image)
			} else {
				ProgressView()
			}
			AsyncImage(url: emoji.remoteImageURL) { phase in
				if let image = phase.image {
					image
						.resizable().scaledToFit()
				} else if phase.error != nil {
					Image(systemName: "xmark.app.fill")
						.resizable().scaledToFit()
						.symbolRenderingMode(.hierarchical)
						.foregroundStyle(.red)
						.onTapGesture {
							id = UUID()
						}
				} else {
					ProgressView()
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
