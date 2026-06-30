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
	@State var jumboMoji: [JumboMoji] = []
	
    var body: some View {
		List {
			TextField("search", text: $searchTerm)
				.autocorrectionDisabled()
				.onChange(of: searchTerm) { term in
					Task.detached {
						let res = await hoarder.trie.search(for: term, previousQuery: nil, previousResult: nil)
						let moji = JumboMoji.from(names: res)
						await MainActor.run {
							self.jumboMoji = moji
						}
					}
				}
			ForEach(jumboMoji, id: \.self) { jumboMoji in
				HStack {
					EmojiCollectionViewRepresentable(
						hoarder: hoarder,
						items: jumboMoji.items,
						width: CGFloat(jumboMoji.width),
						style: .jumboMoji
					)
					.frame(width: 100, height: 100)
					VStack(alignment: .leading) {
						Text(jumboMoji.baseName)
						Text("\(jumboMoji.width) x \(jumboMoji.height)")
					}
				}
			}
		}
    }
}

#Preview {
    JumboMojiTestView(hoarder: EmojiHoarder())
}
