//
//  DownloadedView.swift
//  StickerSlack
//
//  Created by neon443 on 10/11/2025.
//

import SwiftUI

struct DownloadedView: View {
	@ObservedObject var emojiHoarder: EmojiHoarder
	
	var body: some View {
		if emojiHoarder.downloadedStickers.isEmpty {
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
	DownloadedView(emojiHoarder: EmojiHoarder(localOnly: true))
}
