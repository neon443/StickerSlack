//
//  ContentView.swift
//  StickerSlack
//
//  Created by neon443 on 15/10/2025.
//

import SwiftUI
import Haptics

struct ContentView: View {
	@StateObject var hoarder: EmojiHoarder = EmojiHoarder()
	
	var body: some View {
		NavigationView {
			TabView {
				List {
					ForEach(hoarder.emojis, id: \.self) { emoji in
						HStack {
							EmojiPreview(emoji: emoji)
								.frame(maxWidth: 100)
							Spacer()
							Button("", systemImage: "arrow.down.circle") {
								Task {
									let _ = try? await emoji.downloadImage()
									Haptic.success.trigger()
								}
							}
							.buttonStyle(.plain)
						}
						.border(emoji.isLocal ? .red : .clear)
					}
				}
				.tabItem {
					Label("home", systemImage: "house")
				}
			}
		}
	}
}

#Preview {
	ContentView()
}
