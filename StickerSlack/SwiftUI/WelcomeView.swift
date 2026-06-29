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
				Image("icon")
					.resizable().scaledToFit()
					.frame(maxWidth: 75)
				Spacer()
				Text("StickerSlack")
					.bold()
					.font(.largeTitle.monospaced())
				Spacer()
			}
			.padding(.vertical, 16)
			.padding(.leading, 16)
			LazyVGrid(
				columns: Array(
					repeating: GridItem(.flexible(minimum: 50, maximum: 1000)),
					count: UIScreen.main.bounds.width < UIScreen.main.bounds.height ? 2 : 4
				)
			) {
				ListRow(number: 1, text: "Browse or Search", image: Image(uiImage: #imageLiteral(resourceName: "1-browseOrSearch")))
				ListRow(number: 2, text: "Download it", image: Image(systemName: "arrow.down.circle"))
				ListRow(number: 3, text: "Open iMessage", image: Image(systemName: "message.fill"))
				ListRow(number: 4, text: "Tap the +", image: Image(systemName: "plus.circle.fill"))
				ListRow(number: 5, text: "Choose Stickers", image: Image(uiImage: #imageLiteral(resourceName: "stickersIcon.png")))
				ListRow(number: 6, text: "Find StickerSlack", image: Image(uiImage: #imageLiteral(resourceName: "iMessageAppIcon")))
				ListRow(number: 7, text: "Tap a sticker!", image: Image(systemName: "arrow.up.message"))
			}
			.padding()
			.modifier(ScrollContentBackgroundHidden())
			Spacer()
			Group {
				if #available(iOS 19, *) {
					Button() {
						dismiss()
					} label: {
						ContinueButtonView()
					}
					.modifier(glassButtonIfAv())
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
			.tint(.accentColor)
			.interactiveDismissDisabled()
		}
	}
	
	private struct ListRow: View {
		@State var number: Int
		@State var text: String
		@State var image: Image?
		
		var body: some View {
			VStack(alignment: .center) {
				HStack {
					Spacer()
						.overlay(alignment: .leading) {
							Text("\(number)")
								.font(.headline)
								.bold()
								.foregroundStyle(.gray)
						}
					Text(text)
						.lineLimit(nil)
					Spacer()
				}
				image?.resizable().scaledToFit()
					.frame(maxHeight: 40)
			}
			.padding(.bottom)
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
