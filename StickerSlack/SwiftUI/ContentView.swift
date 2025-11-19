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
				DownloadedView(hoarder: hoarder)
					.tabItem {
						Label("Downloaded", systemImage: "arrow.down.circle.fill")
					}
				BrowseView(hoarder: hoarder)
					.tabItem {
						Label("Browse", systemImage: "square.grid.2x2.fill")
					}
				SearchView(hoarder: hoarder)
					.tabItem {
						Label("Search", systemImage: "magnifyingglass")
					}
			}
		}
	}
}

#Preview {
	ContentView(hoarder: EmojiHoarder(localOnly: true))
}
