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
	
	var body: some View {
//		NavigationView {
//			List {
		TextField("", text: $hoarder.searchTerm)
				NavigationLink("trieTester") {
					TrieTestingView(
						hoarder: hoarder,
					)
				}
				
				Text("\(hoarder.searchTerm.isEmpty ? hoarder.emojis.count : hoarder.filteredEmojis.count) Emoji")
				
				EmojiCollectionView(hoarder: hoarder)
				

			.navigationTitle("StickerSlack")
			.onChange(of: hoarder.searchTerm) { _ in
				hoarder.filterEmojis(by: hoarder.searchTerm)
			}
			.refreshable {
				Task.detached {
					await hoarder.refreshDB()
				}
				hoarder.searchTerm = ""
			}
//		}
		.searchable(text: $hoarder.searchTerm, placement: .automatic)
	}
}

#Preview {
	ContentView(hoarder: EmojiHoarder(localOnly: true))
}
