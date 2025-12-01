//
//  ContentView.swift
//  StickerSlack
//
//  Created by neon443 on 15/10/2025.
//

import SwiftUI
import Haptics

struct ContentView: View {
	@ObservedObject var hoarder: EmojiHoarder = EmojiHoarder()
	
	var body: some View {
		Group {
			if #available(iOS 18, *) {
				TabView {
					Tab("Browse", systemImage: "square.grid.2x2.fill") {
						BrowseView(hoarder: hoarder)
					}
					
					Tab("Downloaded", systemImage: "arrow.down.circle.fill") {
						DownloadedView(hoarder: hoarder)
					}
					
					Tab("Settings", systemImage: "gear") {
						SettingsView(hoarder: hoarder)
					}
					
					Tab(role: .search) {
						SearchView(hoarder: hoarder)
					}
				}
			} else {
				TabView {
					BrowseView(hoarder: hoarder)
						.tabItem {
							Label("Browse", systemImage: "square.grid.2x2.fill")
						}
					DownloadedView(hoarder: hoarder)
						.tabItem {
							Label("Downloaded", systemImage: "arrow.down.circle.fill")
						}
					SettingsView(hoarder: hoarder)
						.tabItem {
							Label("Setings", systemImage: "gear")
						}
					SearchView(hoarder: hoarder)
						.tabItem {
							Label("Search", systemImage: "magnifyingglass")
						}
				}
			}
		}
		.sheet(isPresented: $hoarder.showWelcome) {
			hoarder.setShowWelcome(to: false)
		} content: {
			WelcomeView()
		}

	}
}

#Preview {
	ContentView(hoarder: EmojiHoarder(localOnly: true))
}
