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
				
				Text("\(searchTerm.isEmpty ? hoarder.emojis.count : hoarder.filteredEmojis.count) Emoji")
				
				if searchTerm.isEmpty {
					ForEach($hoarder.emojis, id: \.self) { $emoji in
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
									Haptic.heavy.trigger()
								}
								.buttonStyle(.plain)
							} else {
								Button("", systemImage: "arrow.down.circle") {
									Task.detached {
										try? await emoji.downloadImage()
										await MainActor.run {
											emoji.refresh()
											Haptic.success.trigger()
										}
									}
								}
								.buttonStyle(.plain)
							}
						}
					}
				} else {
					ForEach(hoarder.filteredEmojis, id: \.self) { name in
						if let emoji = hoarder.trie.dict[name] {
							EmojiPreview(hoarder: hoarder, emoji: emoji)
								.onTapGesture {
									Task.detached {
										try? await hoarder.trie.dict[name]!.downloadImage()
										await MainActor.run {
											hoarder.trie.dict[name]!.refresh()
										}
									}
								}
						}
					}
				}
			}
			.navigationTitle("StickerSlack")
			.onChange(of: searchTerm) { _ in
				hoarder.filterEmojis(by: searchTerm)
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
