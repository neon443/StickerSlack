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
		NavigationStack {
			TabView {
				List {
					ForEach(hoarder.testBundle.toEmojis(), id: \.self) { emoji in
						Text(emoji.name)
						emoji.image
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
