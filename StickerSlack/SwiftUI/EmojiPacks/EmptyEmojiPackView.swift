//
//  EmptyEmojiPackView.swift
//  StickerSlack
//
//  Created by neon443 on 26/04/2026.
//

import SwiftUI

struct EmptyEmojiPackView: View {
    var body: some View {
		VStack(alignment: .center) {
			HStack {
				Image(systemName: "exclamationmark.triangle.fill")
				Text("No Emoji")
					.bold()
				Image(systemName: "exclamationmark.triangle.fill")
			}
			.foregroundStyle(.yellow)
			Text("This pack contians no emojis")
				.padding(.vertical, 5)
				.foregroundStyle(.foreground)
			Text("Add emojis to this pack by editing it using the pencil button in the toolbar.")
			Text("You can also change the name and description by tapping it in edit mode.")
				.padding(.vertical, 5)
		}
		.transition(.scale)
		.foregroundStyle(.gray)
		.multilineTextAlignment(.center)
		.frame(maxWidth: .infinity)
		.padding()
		.background {
			Color.accentColor.opacity(0.2)
				.clipShape(RoundedRectangle(cornerRadius: 10))
				.blur(radius: 5)
				.shadow(color: .accentColor, radius: 5)
		}
		.padding()
    }
}

#Preview {
    EmptyEmojiPackView()
}
