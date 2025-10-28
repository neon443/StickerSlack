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
	
	@State var searchTerm: String = ""
	
	var body: some View {
		NavigationView {
			TabView {
				List {
					HStack {
						Stepper("show?", value: $hoarder.prefix, step: 100) { $0 }
//						Button("downloaded", systemImage: "arrow.down.circle.fill") {
//							<#code#>
//						}
					}
					ForEach($hoarder.filteredEmojis, id: \.self) { $emoji in
						HStack {
							EmojiPreview(emoji: emoji, image: emoji.image)
								.frame(maxWidth: 100)
							Spacer()
							Button("", systemImage: "arrow.down.circle") {
								Task {
									try? await emoji.downloadImage()
									emoji.refresh()
								}
							}
							.buttonStyle(.plain)
						}
						.id(emoji.uiID)
						.swipeActions(edge: .trailing, allowsFullSwipe: true) {
							if emoji.isLocal {
								Button("Remove", systemImage: "trash") {
									emoji.deleteImage()
									emoji.refresh()
								}
								.tint(.red)
							}
						}
					}
//					.searchable(text: $searchTerm, prompt: "Search")
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
