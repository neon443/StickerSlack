//
//  EmojiRow.swift
//  StickerSlack
//
//  Created by neon443 on 03/11/2025.
//

import SwiftUI
import Haptics

struct EmojiRow: View {
	@ObservedObject var hoarder: EmojiHoarder
	@State var emoji: Emoji
	
	var isLocal: Bool {
		return hoarder.downloadedEmojis.contains(emoji.name)
	}
	
	var body: some View {
		HStack {
			EmojiPreview(hoarder: hoarder, emoji: emoji)
				.frame(width: 100, height: 100)
			
			VStack(alignment: .leading, spacing: 5) {
				ZStack {
					RoundedRectangle(cornerRadius: 5)
						.foregroundStyle(.gray.opacity(0.1))
						.shadow(radius: 2)
					Text(emoji.name)
						.font(.caption)
						.bold(isLocal)
						.foregroundColor(isLocal ? .green : .primary)
						.padding(3)
						.lineLimit(nil)
						.layoutPriority(1)
						.multilineTextAlignment(.leading)
				}
				if isLocal {
					Image(systemName: "arrow.down.circle.fill")
						.resizable().scaledToFit()
						.frame(width: 20, height: 20)
						.symbolRenderingMode(.hierarchical)
						.foregroundStyle(.gray)
						.transition(.scale)
				}
			}
			.padding(.horizontal, 5)
			
			Spacer()
			
			if isLocal {
				Button("", systemImage: "trash") {
					hoarder.delete(emoji: emoji)
				}
				.buttonStyle(.plain)
				.transition(.scale)
			} else {
				Button("", systemImage: "arrow.down.circle") {
					Task {
						await hoarder.download(emoji: emoji)
					}
				}
				.buttonStyle(.plain)
				.transition(.scale)
			}
		}
		.padding(.leading, -1)
		.padding(.trailing, -9)
	}
}

@available(iOS 17, *)
#Preview {
	@Previewable var hoarder = EmojiHoarder(localOnly: true)
	List {
		EmojiRow(hoarder: hoarder, emoji: .test)
		EmojiRow(hoarder: hoarder, emoji: .testLongName)
		ForEach(hoarder.downloadedEmojisArr, id: \.self) { name in
			EmojiRow(hoarder: hoarder, emoji: hoarder.trie.dict[name]!)
		}
	}
}
