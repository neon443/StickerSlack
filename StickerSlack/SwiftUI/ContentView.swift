//
//  ContentView.swift
//  StickerSlack
//
//  Created by neon443 on 15/10/2025.
//

import SwiftUI
import Haptics

struct ContentView: View {
	@ObservedObject var emojiHoarder: EmojiHoarder = EmojiHoarder()
	@ObservedObject var gifhoarder: GifHoarder = GifHoarder()
	
	var body: some View {
		Group {
			if #available(iOS 18, *) {
				TabView {
					Tab("Browse", systemImage: "square.grid.2x2.fill") {
						BrowseView(emojiHoarder: emojiHoarder, gifHoarder: gifhoarder)
					}
					
					Tab("Downloaded", systemImage: "arrow.down.circle.fill") {
						DownloadedView(emojiHoarder: emojiHoarder, gifHoarder: gifhoarder)
					}
					
					Tab("Settings", systemImage: "gear") {
						SettingsView(hoarder: emojiHoarder)
					}
					
					Tab(role: .search) {
						SearchView(hoarder: emojiHoarder)
					}
				}
			} else {
				TabView {
					BrowseView(emojiHoarder: emojiHoarder, gifHoarder: gifhoarder)
						.tabItem {
							Label("Browse", systemImage: "square.grid.2x2.fill")
						}
					DownloadedView(emojiHoarder: emojiHoarder, gifHoarder: gifhoarder)
						.tabItem {
							Label("Downloaded", systemImage: "arrow.down.circle.fill")
						}
					SettingsView(hoarder: emojiHoarder)
						.tabItem {
							Label("Setings", systemImage: "gear")
						}
					SearchView(hoarder: emojiHoarder)
						.tabItem {
							Label("Search", systemImage: "magnifyingglass")
						}
				}
			}
		}
		.sheet(isPresented: $emojiHoarder.showWelcome) {
			emojiHoarder.setShowWelcome(to: false)
		} content: {
			WelcomeView()
		}

	}
}

#Preview {
	ContentView(emojiHoarder: EmojiHoarder(localOnly: false))
}
