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
		VStack {
			HStack {
				Image(systemName: systemImage)
					.resizable()
					.scaledToFit()
					.frame(width: 25)
					.padding(.horizontal, 5)
				Text(title)
					.bold()
					.font(.title3)
			}
			HStack {
				Spacer()
				Text(details)
					.multilineTextAlignment(.center)
					.foregroundStyle(.gray)
				Spacer()
			}
		}
		.listRowSeparator(.hidden)
		.transition(.scale)
		.multilineTextAlignment(.center)
		.frame(maxWidth: .infinity)
		.padding()
		.background {
			Color.accentColor.opacity(0.2)
				.clipShape(RoundedRectangle(cornerRadius: 10))
				.blur(radius: 5)
				.shadow(color: .accentColor, radius: 5)
		}
		.padding()
    }
}

#Preview {
	List {
		EmptyCollectionView(title: "details.title", details: "details.body", systemImage: "gear")
	}
}
