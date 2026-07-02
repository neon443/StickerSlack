//
//  DownloadedView.swift
//  StickerSlack
//
//  Created by neon443 on 10/11/2025.
//

import SwiftUI

struct DownloadedView: View {
	@ObservedObject var emojiHoarder: EmojiHoarder
	@ObservedObject var gifHoarder: GifHoarder
	
	@State private var browseWhat: StickerType = .slackEmoji
	
	var body: some View {
		Picker("", selection: $browseWhat) {
			ForEach(StickerType.allCases) { type in
				Text(type.description)
					.tag(type)
			}
		}
		.pickerStyle(.segmented)
		.padding(.horizontal)
		if emojiHoarder.downloadedStickers.isEmpty && gifHoarder.downloadedStickers.isEmpty {
			NoStickersView()
				.padding()
		}
		
		EmojiCollectionViewRepresentable(
			hoarder: emojiHoarder,
			items: emojiHoarder.downloadedStickersArr,
			width: 75,
			style: .plainWithMenu,
			edit: false
		)
	}
}

#Preview {
	DownloadedView(
		emojiHoarder: EmojiHoarder(localOnly: true),
		gifHoarder: GifHoarder(localOnly: true)
	)
}
