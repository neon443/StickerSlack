//
//  EmojiPackPreview.swift
//  StickerSlack
//
//  Created by neon443 on 01/07/2026.
//

import SwiftUI

struct EmojiPackPreview: View {
	@ObservedObject var hoarder: EmojiHoarder
	@State var pack: EmojiPack
	
	var allDownloaded: Bool {
		pack.allDownloaded(in: hoarder)
	}
	var body: some View {
		NavigationView2 {
			VStack {
				Text(pack.name.isEmpty ? "Name" : pack.name)
					.bold()
					.foregroundStyle(.primary)
					.font(.title)
				
				Text(pack.description.isEmpty ? "Description" : pack.description)
					.foregroundStyle(.primary)
				
				if pack.items.isEmpty {
					EmptyCollectionView(
						title: "No Emoji",
						details: "Add emojis to this pack",
						systemImage: "exclamationmark.triangle.fill"
					)
				}
				
				EmojiCollectionViewRepresentable(
					hoarder: hoarder,
					items: pack.items,
					width: 75,
					style: .full,
					onRemoveSUI: { pack.remove($0) }
				)
				
				if !pack.items.isEmpty {
					Text("\(pack.items.count) Emoji\(pack.items.count.plural)")
						.bold()
						.multilineTextAlignment(.center)
						.shadow(radius: 5)
						.padding(.bottom)
				}
			}
			.transition(.scale)
			.navigationTitle("Pack Details")
			.navigationBarTitleDisplayMode(.inline)
			.onDisappear {
				hoarder.saveEmojiPacks()
			}
		}
	}
}

#Preview {
	EmojiPackPreview(hoarder: EmojiHoarder(), pack: .test)
}
