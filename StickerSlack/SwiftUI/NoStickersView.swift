//
//  NoStickersView.swift
//  StickerSlack
//
//  Created by neon443 on 05/04/2026.
//

import SwiftUI

struct NoStickersView: View {
    var body: some View {
		VStack(alignment: .center) {
			Image(systemName: "questionmark.app.dashed")
				.resizable().scaledToFit()
				.frame(width: 75, height: 75)
			Text("No Downloaded Stickers")
				.font(.title)
				.bold()
			Text("Download some Slack Emojis or GIFs to use in iMessage!")
				.foregroundStyle(.gray)
				.multilineTextAlignment(.center)
		}
    }
}

#Preview {
    NoStickersView()
}
