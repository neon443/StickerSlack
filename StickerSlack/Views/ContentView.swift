//
//  ContentView.swift
//  StickerSlack
//
//  Created by neon443 on 15/10/2025.
//

import SwiftUI

struct ContentView: View {
	@StateObject var hoarder: EmojiHoarder = EmojiHoarder()
	
	var body: some View {
		NavigationView {
			TabView {
				List {
					ForEach(hoarder.emojis, id: \.self) { emoji in
						EmojiPreview(emoji: emoji)
							.frame(maxWidth: 100)
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
