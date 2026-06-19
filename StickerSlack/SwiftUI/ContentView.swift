//
//  ContentView.swift
//  StickerSlack
//
//  Created by neon443 on 15/10/2025.
//

import SwiftUI
import Haptics

struct ContentView: View {
	@ObservedObject var emojiHoarder: EmojiHoarder
	@ObservedObject var gifhoarder: GifHoarder
	
	var body: some View {
		Group {
			if #available(iOS 18, *) {
				TabView {
					Tab("Browse", systemImage: "square.grid.2x2.fill") {
						BrowseView(emojiHoarder: emojiHoarder, gifHoarder: gifhoarder)
					}
					
					Tab("Packs", systemImage: "square.stack.3d.up.fill") {
						EmojiPackManager(hoarder: emojiHoarder)
					}
					
					Tab("Downloaded", systemImage: "arrow.down.circle.fill") {
						DownloadedView(emojiHoarder: emojiHoarder, gifHoarder: gifhoarder)
					}
					
					Tab("Settings", systemImage: "gear") {
						SettingsView(hoarder: emojiHoarder)
					}
					
					Tab(role: .search) {
						NavigationStack {
							SearchView(hoarder: emojiHoarder)
						}
					}
				}
				.tabViewBottomAccessorySafe {
					HStack {
						Image(systemName: "magnifyingglass")
						TextField("", text: .constant("sa"), prompt: Text("Search"))
					}
					.padding(.horizontal)
				}
			} else {
				TabView {
					BrowseView(emojiHoarder: emojiHoarder, gifHoarder: gifhoarder)
						.tabItem {
							Label("Browse", systemImage: "square.grid.2x2.fill")
						}
					EmojiPackManager(hoarder: emojiHoarder)
						.tabItem {
							Label("Packs", systemImage: "square.stack.3d.up.fill")
						}
					DownloadedView(emojiHoarder: emojiHoarder, gifHoarder: gifhoarder)
						.tabItem {
							Label("Downloaded", systemImage: "arrow.down.circle.fill")
						}
					SettingsView(hoarder: emojiHoarder)
						.tabItem {
							Label("Setings", systemImage: "gear")
						}
					NavigationView2 {
						SearchView(hoarder: emojiHoarder)
					}
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
	ContentView(emojiHoarder: EmojiHoarder(localOnly: false), gifhoarder: GifHoarder(localOnly: false))
}
