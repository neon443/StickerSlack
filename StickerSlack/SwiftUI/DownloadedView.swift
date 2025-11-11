//
//  DownloadedView.swift
//  StickerSlack
//
//  Created by neon443 on 10/11/2025.
//

import SwiftUI

struct DownloadedView: View {
	@ObservedObject var hoarder: EmojiHoarder = .shared
	
	@Environment(\.colorScheme) var colorScheme
	var isDark: Bool { colorScheme == .dark }
	
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
		ScrollView {
			let columns: Int = max(1, Int((UIScreen.main.bounds.width - 2*spacing) / (minColWidth + spacing)))
			let layout = Array(repeating: col, count: columns)
			LazyVGrid(columns: layout, spacing: spacing) {
				ForEach(hoarder.emojis, id: \.self) { emoji in
					if hoarder.downloadedEmojis.contains(emoji.name) {
						ZStack {
							Rectangle()
								.foregroundStyle(isDark ? .black : .white)
							EmojiPreview(emoji: emoji)
							RoundedRectangle(cornerRadius: 15)
								.stroke(.gray, lineWidth: 1)
						}
						.aspectRatio(1, contentMode: .fit)
						.clipShape(RoundedRectangle(cornerRadius: 15))
						.contextMenu {
							Text(emoji.name)
							Button("Copy Name", systemImage: "document.on.document") {
								UIPasteboard.general.string = emoji.name
							}
							Button("Copy Image", systemImage: "photo.fill.on.rectangle.fill") {
								UIPasteboard.general.image = emoji.image
							}
							Divider()
							ShareLink("Share", item: emoji.remoteImageURL, subject: nil, message: nil)
							Divider()
							Button("Delete", systemImage: "trash.fill", role: .destructive) {
								hoarder.delete(emoji: emoji)
							}
						}
					}
				}
			}
			.padding(.horizontal, spacing)
		}
	}
}

#Preview {
	DownloadedView()
}
