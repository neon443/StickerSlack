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
			List {
				NavigationLink("trieTester") {
					TrieTestingView(
						hoarder: hoarder,
					)
				}
				
//				Button("none") {
//					hoarder.filterEmojis(byCategory: .none, searchTerm: searchTerm)
//				}
//				
//				Button("downloaded") {
//					hoarder.filterEmojis(byCategory: .downloaded, searchTerm: searchTerm)
//				}
//				
//				Button("not downloaded") {
//					hoarder.filterEmojis(byCategory: .notDownloaded, searchTerm: searchTerm)
//				}
				
				Button("delete all images") {
					Task.detached {
						await hoarder.deleteAllStickers()
					}
				}
				
				Text("\(hoarder.filteredEmojis.count) Emoji")
				
//				if searchTerm.isEmpty {
					ForEach($hoarder.filteredEmojis, id: \.self) { $emoji in
						HStack {
							EmojiPreview(
								hoarder: hoarder,
								emoji: emoji
							)
							.frame(maxWidth: 100, maxHeight: 100)
							Spacer()
							if emoji.isLocal {
								Button("", systemImage: "trash") {
									emoji.deleteImage()
									emoji.refresh()
								}
								.buttonStyle(.plain)
							} else {
								Button("", systemImage: "arrow.down.circle") {
									Task.detached {
										try? await emoji.downloadImage()
										await MainActor.run {
											emoji.refresh()
										}
									}
								}
								.buttonStyle(.plain)
							}
						}
					}
//				} else {
//					ForEach(hoarder.filteredEmojis, id: \.self) { name in
//						Text(name)
//					}
//				}
			}
			.navigationTitle("StickerSlack")
			.onChange(of: searchTerm) { _ in
//				hoarder.filterEmojis(by: searchTerm)
				hoarder.results(for: searchTerm)
			}
			.refreshable {
				Task.detached {
					await hoarder.refreshDB()
				}
				searchTerm = ""
			}
		}
		.searchable(text: $searchTerm, placement: .automatic)
	}
}

#Preview {
	ContentView(hoarder: EmojiHoarder(localOnly: true))
}
