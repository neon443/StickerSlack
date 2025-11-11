//
//  BrowseView.swift
//  StickerSlack
//
//  Created by neon443 on 10/11/2025.
//

import SwiftUI

struct BrowseView: View {
	@ObservedObject var hoarder: EmojiHoarder
	
    var body: some View {
		List {
			ForEach(hoarder.emojis, id: \.self) { emoji in
				EmojiRow(hoarder: hoarder, emoji: emoji)
			}
		}
    }
}

#Preview {
    BrowseView(hoarder: EmojiHoarder(localOnly: true))
}
