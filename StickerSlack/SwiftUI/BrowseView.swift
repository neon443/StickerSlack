//
//  BrowseView.swift
//  StickerSlack
//
//  Created by neon443 on 10/11/2025.
//

import SwiftUI

struct BrowseView: View {
	@ObservedObject var hoarder: EmojiHoarder = .shared
	
    var body: some View {
		List {
			ForEach(hoarder.emojis, id: \.self) { emoji in
				EmojiRow(emoji: emoji)
			}
		}
    }
}

#Preview {
    BrowseView()
}
