//
//  ListRow.swift
//  StickerSlack
//
//  Created by neon443 on 21/11/2025.
//

import SwiftUI

struct ListRow: View {
	@State var number: Int
	@State var text: String
	
	var body: some View {
		HStack {
			Text("\(number)")
				.padding(.trailing, 10)
				.foregroundStyle(.gray)
			Text(text)
		}
	}
}

#Preview {
    ListRow(number: 1, text: "hi!")
}
