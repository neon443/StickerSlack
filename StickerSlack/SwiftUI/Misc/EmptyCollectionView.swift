//
//  EmptyCollectionView.swift
//  StickerSlack
//
//  Created by neon443 on 10/04/2026.
//

import SwiftUI

struct EmptyCollectionView: View {
	@State var title: String
	@State var details: String
	@State var systemImage: String
	
    var body: some View {
		ZStack {
			Color.accentColor
				.opacity(0.4)
				.padding(.horizontal, -15)
				.padding(.vertical, -15)
				.blur(radius: 5)
			HStack {
				Image(systemName: systemImage)
					.resizable()
					.scaledToFit()
					.frame(width: 25)
				Text(title)
					.bold()
					.font(.title3)
			}
		}
		.listRowSeparator(.hidden)
		HStack {
			Spacer()
			Text(details)
				.multilineTextAlignment(.center)
			Spacer()
		}
    }
}

#Preview {
	List {
		EmptyCollectionView(title: "details.title", details: "details.body", systemImage: "gear")
	}
}
