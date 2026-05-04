//
//  JumboMojiTestView.swift
//  StickerSlack
//
//  Created by neon443 on 04/05/2026.
//

import SwiftUI

struct JumboMojiTestView: View {
	@State var hoarder: EmojiHoarder
	@State var searchTerm: String = ""
	@State var searchResult: [String] = []
	
    var body: some View {
		List {
			TextField("search", text: $searchTerm)
				.autocorrectionDisabled()
				.onChange(of: searchTerm) { _ in
					searchResult = hoarder.trie.search(for: searchTerm, previousQuery: nil, previousResult: nil)
				}
			ForEach(JumboMoji.from(names: searchResult), id: \.self) { jumboMoji in
				VStack {
//					ForEach(0..<jumboMoji.height, id: \.self) { row in
//						ForEach(0..<jumboMoji.width, id: \.self) { col in
//							StickerPreview(sticker: hoarder.trie.dict[jumboMoji.items[row+col]] ?? .test)
//						}
//					}
					EmojiCollectionView(
						hoarder: hoarder,
						items: jumboMoji.items,
						pack: nil,
						width: CGFloat(jumboMoji.width),
						style: .jumboMoji,
						animate: false
					)
					.frame(width: 100, height: 100)
					Text(jumboMoji.description)
				}
			}
			Divider()
//			ForEach(searchResult, id: \.self) { item in
//				Text(item)
//					.border(JumboMoji.splitIntoComponents(string: item) == nil ? .clear : .red)
//					.foregroundStyle(.gray)
//			}
		}
    }
}

#Preview {
    JumboMojiTestView(hoarder: EmojiHoarder())
}
