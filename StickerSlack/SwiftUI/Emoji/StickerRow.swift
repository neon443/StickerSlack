//
//  EmojiRow.swift
//  StickerSlack
//
//  Created by neon443 on 03/11/2025.
//

import SwiftUI
import Haptics

struct StickerRow<T: Hoarder>: View {
	@ObservedObject var hoarder: T
	@State var emoji: any StickerProtocol
	@State var showTooltip: Bool = false
	
	var isLocal: Bool {
		return hoarder.downloadedStickers.contains(emoji.name)
	}
	
	var body: some View {
		HStack {
			StickerPreview(emoji: emoji)
				.frame(width: 100, height: 100)
				.transition(.scale)
			
			VStack(alignment: .leading, spacing: 5) {
				Text(emoji.name)
					.font(.caption)
					.bold(isLocal)
					.foregroundColor(isLocal ? .green : .primary)
					.lineLimit(nil)
					.multilineTextAlignment(.leading)
				HStack(spacing: 5) {
					Button {
						showTooltip.toggle()
					} label: {
						Image("slack.logo")
							.resizable().scaledToFit()
							.frame(width: 20, height: 20)
							.foregroundStyle(.gray)
					}
					.buttonStyle(.borderless)
					.alert("From Slack", isPresented: $showTooltip) {
						Button("Done") {}
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
			}
			.padding(5)
			.background(
				RoundedRectangle(cornerRadius: 15)
					.foregroundStyle(.gray.opacity(0.1))
					.shadow(radius: 2)
			)
			
			Spacer()
			
			if isLocal {
				Button("", systemImage: "trash") {
					hoarder.delete(emoji: emoji, skipStoreIndex: false)
				}
				.buttonStyle(.plain)
				.transition(.scale)
			} else {
				Button("", systemImage: "arrow.down.circle") {
					Task.detached {
						await hoarder.download(emoji: emoji, skipStoreIndex: false)
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
		StickerRow(hoarder: hoarder, emoji: Emoji.test)
		StickerRow(hoarder: hoarder, emoji: Emoji.testLongName)
		StickerRow(hoarder: hoarder, emoji: Gif.test)
		StickerRow(hoarder: hoarder, emoji: Emoji(name: "a", url: Emoji.test.remoteImageURL))
		StickerRow(hoarder: hoarder, emoji: Emoji(name: "ab", url: Emoji.test.remoteImageURL))
		StickerRow(hoarder: hoarder, emoji: Emoji(name: "abc", url: Emoji.test.remoteImageURL))
		StickerRow(hoarder: hoarder, emoji: Emoji(name: "abcd", url: Emoji.test.remoteImageURL))
		StickerRow(hoarder: hoarder, emoji: Emoji(name: "abcde", url: Emoji.test.remoteImageURL))
		StickerRow(hoarder: hoarder, emoji: Emoji(name: "abcdef", url: Emoji.test.remoteImageURL))
		StickerRow(hoarder: hoarder, emoji: Emoji(name: "abcdefg", url: Emoji.test.remoteImageURL))
		StickerRow(hoarder: hoarder, emoji: Emoji(name: "abcdefgh", url: Emoji.test.remoteImageURL))
		ForEach(hoarder.downloadedEmojisArr, id: \.self) { name in
			if let emoji = hoarder.trie.dict[name] {
				StickerRow(hoarder: hoarder, emoji: emoji)
			}
		}
	}
}
