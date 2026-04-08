//
//  WelcomeView.swift
//  StickerSlack
//
//  Created by neon443 on 21/11/2025.
//

import SwiftUI

struct WelcomeView: View {
	@Environment(\.dismiss) var dismiss
	@Environment(\.colorScheme) var colourScheme
	var isDark: Bool {
		return colourScheme == .dark
	}
	
	var body: some View {
		VStack(spacing: 0) {
			HStack {
				Image("icon\(isDark ? "-dark" : "")")
					.resizable().scaledToFit()
					.frame(maxWidth: 75)
				Spacer()
				Text("StickerSlack")
					.bold()
					.font(.largeTitle)
					.monospaced()
				Spacer()
			}
			.padding(.vertical, 20)
			.padding(.leading, 20)
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
			Group {
				if #available(iOS 19, *) {
					Button() {
						dismiss()
					} label: {
						ContinueButtonView()
					}
					.buttonStyle(.glassProminent)
				} else {
					Button() {
						dismiss()
					} label: {
						ContinueButtonView()
					}
					.buttonStyle(.borderedProminent)
				}
			}
			.padding(.bottom)
			.tint(.purple)
			.interactiveDismissDisabled()
		}
	}
}

fileprivate struct ContinueButtonView: View {
	var body: some View {
		Text("Continue")
			.font(.title)
			.bold()
	}
}

#Preview {
	Color.gray.opacity(0.5)
		.ignoresSafeArea(.all)
		.sheet(isPresented: .constant(true)) {
			WelcomeView()
		}
}
