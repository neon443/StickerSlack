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
					TextField("", text: $searchTerm) {
						hoarder.filterEmojis(by: searchTerm)
					}
					
					.autocorrectionDisabled()
					.textFieldStyle(.roundedBorder)
					
					Text("\(hoarder.filteredEmojis.count) Emoji")
					
					ForEach($hoarder.filteredEmojis, id: \.self) { $emoji in
						HStack {
							EmojiPreview(emoji: emoji)
								.frame(maxWidth: 100)
							Spacer()
							if emoji.isLocal {
								Button("", systemImage: "trash") {
									emoji.deleteImage()
								}
								.buttonStyle(.plain)
							} else {
								Button("", systemImage: "arrow.down.circle") {
									Task {
										try? await emoji.downloadImage()
										emoji.refresh()
									}
								}
								.buttonStyle(.plain)
							}
						}
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
				.searchable(text: $searchTerm)
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
