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
			AsyncImage(url: emoji.url) { phase in
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
			.frame(width: 50, height: 50)
		}
    }
}

#Preview {
	EmojiPreview(
		emoji: Emoji(
			name: "s?",
			url: "https://neon443.github.io/images/fav.ico"
		)
	)
}
