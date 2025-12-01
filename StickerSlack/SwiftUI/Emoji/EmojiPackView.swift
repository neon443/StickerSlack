//
//  EmojiPackView.swift
//  StickerSlack
//
//  Created by neon443 on 01/12/2025.
//

import SwiftUI

struct EmojiPackView: View {
	@State var pack: EmojiPack
	
	var body: some View {
		Text(pack.name)
			.bold()
		Text(pack.description)
			.foregroundStyle(.gray)
	}
}

#Preview {
	EmojiPackView(pack: .test)
}
