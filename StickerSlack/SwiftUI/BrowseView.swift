//
//  BrowseView.swift
//  StickerSlack
//
//  Created by neon443 on 10/11/2025.
//

import SwiftUI
import Haptics

struct BrowseView: View {
	@ObservedObject var emojiHoarder: EmojiHoarder
	
	var body: some View {
		VStack {
			EmojiTableViewRepresentable(
				hoarder: emojiHoarder,
				items: emojiHoarder.emojis.map { $0.name }
			)
			.padding(.bottom, 10)
		}
	}
}

#Preview {
	BrowseView(emojiHoarder: EmojiHoarder(localOnly: true))
}
