//
//  BrowseView.swift
//  StickerSlack
//
//  Created by neon443 on 10/11/2025.
//

import SwiftUI

struct BrowseView: View {
	@State private var browseWhat: StickerType = .slackEmoji
	@ObservedObject var hoarder: EmojiHoarder
	@ObservedObject var gifHoarder: GifHoarder
	
    var body: some View {
		List {
			Picker("", selection: $browseWhat) {
				ForEach(StickerType.allCases, id: \.self) { type in
					Text(type.description)
				}
			}
			.pickerStyle(.segmented)
			switch browseWhat {
			case .slackEmoji:
				ForEach(hoarder.emojis, id: \.self) { emoji in
					EmojiRow(hoarder: hoarder, emoji: emoji)
						.listRowSeparator(.hidden)
				}
			case .giphyGifs:
				ForEach(gifHoarder.trendingGifs) { gif in
					EmojiRow(hoarder: hoarder, emoji: gif)
				}
			}
		}
    }
}

#Preview {
	BrowseView(
		hoarder: EmojiHoarder(localOnly: true),
		gifHoarder: GifHoarder(localOnly: true)
	)
}
