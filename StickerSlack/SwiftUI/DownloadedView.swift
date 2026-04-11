//
//  DownloadedView.swift
//  StickerSlack
//
//  Created by neon443 on 10/11/2025.
//

import SwiftUI

struct DownloadedView: View {
	@ObservedObject var emojiHoarder: EmojiHoarder
	@ObservedObject var gifHoarder: GifHoarder
	
	@Environment(\.colorScheme) var colorScheme
	var isDark: Bool { colorScheme == .dark }
	@State var browseWhat: StickerType = .slackEmoji
	
	@State var showShare: Bool = false
	
	var minColWidth: CGFloat { 75 }
	var spacing: CGFloat { 5 }
	var col: GridItem {
		GridItem(
			.flexible(minimum: minColWidth, maximum: 100),
			spacing: spacing,
			alignment: .center
		)
	}
	
	var body: some View {
		Picker("", selection: $browseWhat) {
			ForEach(StickerType.allCases) { type in
				Text(type.description)
					.tag(type)
			}
		}
		.pickerStyle(.segmented)
		if emojiHoarder.downloadedStickers.isEmpty && gifHoarder.downloadedStickers.isEmpty {
			NoStickersView()
				.padding()
		}
		GeometryReader { geo in
			ScrollView {
				let columns: Int = max(1, Int((geo.size.width - 2*spacing) / (minColWidth + spacing)))
				let layout = Array(repeating: col, count: columns)
				LazyVGrid(columns: layout, spacing: spacing) {
					ForEach(emojiHoarder.downloadedStickersArr, id: \.self) { name in
						if let emoji = emojiHoarder.trie.dict[name] {
							ZStack {
								Rectangle()
									.foregroundStyle(isDark ? .black : .white)
								StickerPreview(sticker: emoji)
								RoundedRectangle(cornerRadius: 15)
									.stroke(.gray, lineWidth: 1)
							}
							.aspectRatio(1, contentMode: .fit)
							.clipShape(RoundedRectangle(cornerRadius: 15))
							.contextMenu {
								Text(emoji.UIName)
								Button("Copy Name", systemImage: "doc.on.clipboard") {
									UIPasteboard.general.string = emoji.UIName
								}
								Button("Copy Image", systemImage: "photo.fill.on.rectangle.fill") {
									UIPasteboard.general.image = emoji.image
								}
								Divider()
								if #available(iOS 16, *) {
									ShareLink(item: emoji.remoteImageURL) {
										Label("Share", systemImage: "square.and.arrow.up")
									}
								} else {
									Button("Share", systemImage: "square.and.arrow.up") {
										showShare.toggle()
									}
									.sheet(isPresented: $showShare) {
										ShareSheet(activityItems: [emoji.remoteImageURL])
									}
								}
								Divider()
								Button("Delete", systemImage: "trash.fill", role: .destructive) {
									emojiHoarder.delete(emoji: emoji)
								}
							}
						}
					}
				}
				.padding(.horizontal, spacing)
			}
		}
	}
}

#Preview {
	DownloadedView(
		emojiHoarder: EmojiHoarder(localOnly: true),
		gifHoarder: GifHoarder(localOnly: true)
	)
}
