//
//  BrowseView.swift
//  StickerSlack
//
//  Created by neon443 on 10/11/2025.
//

import SwiftUI

struct BrowseView: View {
	@State private var browseWhat: StickerType = .slackEmoji
	@ObservedObject var emojiHoarder: EmojiHoarder
	@ObservedObject var gifHoarder: GifHoarder
	
    var body: some View {
		List {
			Picker("", selection: $browseWhat) {
				ForEach(StickerType.allCases) { type in
					Text(type.description).tag(type)
				}
			}
			.pickerStyle(.segmented)
			switch browseWhat {
			case .slackEmoji:
				ForEach(emojiHoarder.emojis, id: \.self) { emoji in
					StickerRow(hoarder: emojiHoarder, emoji: emoji)
						.listRowSeparator(.hidden)
				}
			case .giphyGifs:
				ForEach(gifHoarder.trendingGifs) { gif in
					StickerRow(hoarder: emojiHoarder, emoji: gif)
						.listRowSeparator(.hidden)
				}
			}
		}
    }
}

#Preview {
	BrowseView(
		emojiHoarder: EmojiHoarder(localOnly: true),
		gifHoarder: GifHoarder(localOnly: true)
	)
}
