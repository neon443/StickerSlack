//
//  EmojiPackView.swift
//  StickerSlack
//
//  Created by neon443 on 01/12/2025.
//

import SwiftUI

struct EmojiPackView: View {
	@ObservedObject var hoarder: EmojiHoarder
	@State var pack: EmojiPack
	
	var body: some View {
		Text(pack.name)
			.bold()
		Text(pack.description)
			.foregroundStyle(.gray)
		ForEach(pack.emojiNames, id: \.self) { name in
			EmojiPreview(hoarder: hoarder, emoji: hoarder.trie.dict[name] ?? .test)
		}
	}
}

#Preview {
	EmojiPackView(
		hoarder: EmojiHoarder(localOnly: true, skipIndex: true),
		pack: .test
	)
}
