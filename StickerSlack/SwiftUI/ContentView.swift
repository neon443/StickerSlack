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
	
	@State var tabSelection: AppTab = .browse
	@State var searchTerm: String = ""
	
	enum AppTab {
		case browse
		case packs
		case downloaded
		case settings
		case search
	}
	
	var body: some View {
		Group {
			if #available(iOS 18, *) {
				TabView(selection: $tabSelection) {
					Tab("Browse", systemImage: "square.grid.2x2.fill", value: AppTab.browse) {
						BrowseView(emojiHoarder: emojiHoarder, gifHoarder: gifhoarder)
					}
					
					Tab("Packs", systemImage: "square.stack.3d.up.fill", value: AppTab.packs) {
						EmojiPackManager(hoarder: emojiHoarder)
					}
					
					Tab("Downloaded", systemImage: "arrow.down.circle.fill", value: AppTab.downloaded) {
						DownloadedView(emojiHoarder: emojiHoarder, gifHoarder: gifhoarder)
					}
					
					Tab("Settings", systemImage: "gear", value: AppTab.settings) {
						SettingsView(hoarder: emojiHoarder)
					}
					
					Tab(value: AppTab.search, role: .search) {
						NavigationStack {
							SearchView(hoarder: emojiHoarder, searchTerm: $searchTerm)
						}
					}
				}
//				.tabViewBottomAccessorySafe() {
//					HStack {
//						Image(systemName: "magnifyingglass")
//						TextField("", text: $searchTerm, prompt: Text("Search"))
//					}
//					.padding(.horizontal)
//				}
			} else {
				TabView(selection: $tabSelection) {
					BrowseView(emojiHoarder: emojiHoarder, gifHoarder: gifhoarder)
						.tag(AppTab.browse)
						.tabItem {
							Label("Browse", systemImage: "square.grid.2x2.fill")
						}
					EmojiPackManager(hoarder: emojiHoarder)
						.tag(AppTab.packs)
						.tabItem {
							Label("Packs", systemImage: "square.stack.3d.up.fill")
						}
					DownloadedView(emojiHoarder: emojiHoarder, gifHoarder: gifhoarder)
						.tag(AppTab.downloaded)
						.tabItem {
							Label("Downloaded", systemImage: "arrow.down.circle.fill")
						}
					SettingsView(hoarder: emojiHoarder)
						.tag(AppTab.settings)
						.tabItem {
							Label("Setings", systemImage: "gear")
						}
					NavigationView2 {
						SearchView(hoarder: emojiHoarder, searchTerm: $searchTerm)
					}
					.tag(AppTab.search)
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
