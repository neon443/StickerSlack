//
//  EmojiPackManager.swift
//  StickerSlack
//
//  Created by neon443 on 01/12/2025.
//

import SwiftUI

struct EmojiPackManager: View {
	@ObservedObject var hoarder: EmojiHoarder
	
	var body: some View {
		ForEach(hoarder.emojiPacks) { pack in
			EmojiPackDetailView(hoarder: hoarder, pack: pack)
		}
		EmojiPackDetailView(hoarder: hoarder, pack: .test)
	}
}

#Preview {
	EmojiPackManager(
		hoarder: EmojiHoarder(localOnly: true, skipIndex: true)
	)
}
