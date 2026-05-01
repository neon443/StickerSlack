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
	@State var sticker: any StickerProtocol
	@State var showTooltip: Bool = false
	@State var downloading: Bool = false
	
	var isDownloaded: Bool {
		return hoarder.downloadedStickers.contains(sticker.name)
	}
	
	var body: some View {
		HStack {
			StickerPreview(sticker: sticker)
				.frame(width: 100, height: 100)
				.transition(.scale)
			
			VStack(alignment: .leading, spacing: 5) {
				Text(sticker.UIName)
					.font(.caption.bold())
					.foregroundColor(isDownloaded ? .green : .primary)
					.lineLimit(nil)
					.multilineTextAlignment(.leading)
				VStack(alignment: .leading, spacing: 5) {
					Button {
						showTooltip.toggle()
					} label: {
						Image(sticker.typeGlyph)
							.resizable().scaledToFit()
							.frame(maxHeight: 20)
							.foregroundStyle(.gray)
					}
					.tint(isDownloaded ? .red : .accent)
					.buttonStyle(.borderless)
					.alert("From \(sticker.type.fromAppName)", isPresented: $showTooltip) {
						Button("Done") {}
					}
					if isDownloaded {
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
					.foregroundStyle(.gray.opacity(0.2))
			)
			
			Spacer()
				
			Group {
				if sticker.type == .slackEmoji {
					AddToPackMenuView(
						emojiHoarder: hoarder as! EmojiHoarder,
						sticker: sticker as! Emoji
					)
					.padding(.trailing, -8)
				}
				
				if isDownloaded {
					Button {
						Task {
							await hoarder.delete(emoji: sticker, skipStoreIndex: false)
							downloading = false
						}
					} label: {
						Image(systemName: "trash")
							.resizable().scaledToFit()
					}
					.transition(.scale)
				} else if downloading {
					ProgressView()
						.transition(.scale)
						.padding(.trailing)
				} else {
					Button {
						withAnimation(.snappy) {
							downloading = true
						}
						Task.detached {
							await hoarder.download(emoji: sticker, skipStoreIndex: false)
						}
					} label: {
						Image(systemName: "arrow.down.circle")
							.resizable().scaledToFit()
					}
					.transition(.scale)
				}
			}
			.frame(width: 24, height: 24)
			.padding(.trailing)
		}
	}
}

@available(iOS 17, *)
#Preview {
	@Previewable var hoarder = EmojiHoarder()
	List {
		ForEach(hoarder.emojis.prefix(10)) { emoji in
			StickerRow(hoarder: hoarder, sticker: emoji)
		}
//		EmojiTableView(
//			hoarder: hoarder,
//			items: hoarder.emojis.prefix(10).map({ <#Emoji#> in
//				<#code#>
//			})
//		)
//		StickerRow(hoarder: hoarder, sticker: Emoji.test)
//		StickerRow(hoarder: hoarder, sticker: Emoji.testLongName)
//		StickerRow(hoarder: hoarder, sticker: Gif.test)
//		StickerRow(hoarder: hoarder, sticker: Emoji(name: "a", url: Emoji.test.remoteImageURL))
//		StickerRow(hoarder: hoarder, sticker: Emoji(name: "ab", url: Emoji.test.remoteImageURL))
//		StickerRow(hoarder: hoarder, sticker: Emoji(name: "abc", url: Emoji.test.remoteImageURL))
//		StickerRow(hoarder: hoarder, sticker: Emoji(name: "abcd", url: Emoji.test.remoteImageURL))
//		StickerRow(hoarder: hoarder, sticker: Emoji(name: "abcde", url: Emoji.test.remoteImageURL))
//		StickerRow(hoarder: hoarder, sticker: Emoji(name: "abcdef", url: Emoji.test.remoteImageURL))
//		StickerRow(hoarder: hoarder, sticker: Emoji(name: "abcdefg", url: Emoji.test.remoteImageURL))
//		StickerRow(hoarder: hoarder, sticker: Emoji(name: "abcdefgh", url: Emoji.test.remoteImageURL))
	}
}
