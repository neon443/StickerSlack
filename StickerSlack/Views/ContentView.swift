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
					TextField("", text: $searchTerm)
						.onChange(of: searchTerm) { _ in
							hoarder.filterEmojis(by: searchTerm)
						}
					.autocorrectionDisabled()
					.textFieldStyle(.roundedBorder)
					
					Button("none") {
						hoarder.filterEmojis(byCategory: .none, searchTerm: searchTerm)
					}
					
					Button("downloaded") {
						hoarder.filterEmojis(byCategory: .downloaded, searchTerm: searchTerm)
					}
					
					Button("not downloaded") {
						hoarder.filterEmojis(byCategory: .notDownloaded, searchTerm: searchTerm)
					}
					
					Text("\(hoarder.filteredEmojis.count) Emoji")
					
					ForEach($hoarder.filteredEmojis, id: \.self) { $emoji in
						HStack {
							EmojiPreview(emoji: emoji)
								.frame(maxWidth: 100, maxHeight: 100)
							Spacer()
							Button("", systemImage: "checkmark") {
								print(emoji.sticker?.validate())
							}
							Spacer()
							if emoji.isLocal {
								Button("", systemImage: "trash") {
									emoji.deleteImage()
									emoji.refresh()
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
				}
				.refreshable {
					hoarder.refreshDB() {
						hoarder.filterEmojis(by: searchTerm)
					}
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
