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
		VStack {
			Picker("", selection: $browseWhat) {
				ForEach(StickerType.allCases) { type in
					Text(type.description).tag(type)
				}
			}
			.pickerStyle(.segmented)
			.padding(.horizontal)
			Group {
				switch browseWhat {
				case .slackEmoji:
					EmojiTableView(
						hoarder: emojiHoarder,
						items: emojiHoarder.emojis.map { $0.name }
					)
					.ignoresSafeArea(.container, edges: .bottom)
					.id(emojiHoarder.emojis)
				case .giphyGifs:
					Button("download all") {
						Task {
							for gif in gifHoarder.trendingGifs {
								await gifHoarder.download(emoji: gif)
							}
						}
					}
					Button("del all") {
						for gif in gifHoarder.trendingGifs {
							gifHoarder.delete(emoji: gif)
						}
					}
					List {
						ForEach(gifHoarder.trendingGifs) { gif in
							StickerRow(hoarder: gifHoarder, sticker: gif)
						}
					}
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
