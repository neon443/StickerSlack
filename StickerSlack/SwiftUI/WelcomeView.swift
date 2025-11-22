//
//  WelcomeView.swift
//  StickerSlack
//
//  Created by neon443 on 21/11/2025.
//

import SwiftUI

struct WelcomeView: View {
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		VStack {
			Text("StickerSlack")
				.bold()
				.font(.largeTitle)
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
			Spacer()
			if #available(iOS 19, *) {
				Button() {
					dismiss()
				} label: {
					Text("Continue")
						.font(.title)
						.bold()
				}
				.buttonStyle(.glassProminent)
				.padding(.bottom)
			} else {
				Button() {
					dismiss()
				} label: {
					Text("Continue")
						.font(.title)
						.bold()
				}
				.buttonStyle(.borderedProminent)
				.padding(.bottom)
			}
		}
	}
}

#Preview {
	Color.gray.opacity(0.5)
		.ignoresSafeArea(.all)
		.sheet(isPresented: .constant(true)) {
			WelcomeView()
		}
}
