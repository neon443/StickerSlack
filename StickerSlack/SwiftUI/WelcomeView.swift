//
//  WelcomeView.swift
//  StickerSlack
//
//  Created by neon443 on 21/11/2025.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
		VStack {
			Text("StickerSlack")
				.bold()
				.font(.title)
				.monospaced()
				.padding()
			List {
				Section("How to use") {
					ListRow(number: 1, text: "Browse or search for an emoji")
					ListRow(number: 2, text: "Download it")
					ListRow(number: 3, text: "Open iMessage")
					ListRow(number: 4, text: "Press the +")
					ListRow(number: 5, text: "Choose StickerSlack")
					ListRow(number: 6, text: "Tap an emoji to use it!")
				}
			}
			.scrollContentBackground(.hidden)
		}
    }
}

#Preview {
    WelcomeView()
}
