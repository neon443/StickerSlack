//
//  EmojiPackImporterView.swift
//  StickerSlack
//
//  Created by neon443 on 10/04/2026.
//

import SwiftUI

struct EmojiPackImporterView: View {
	@ObservedObject var emojiHoarder: EmojiHoarder
	@Binding var pack: EmojiPack
	@Environment(\.dismiss) var dismiss
	var isiPhone: Bool {
		return UIDevice().userInterfaceIdiom == .phone
	}
	
    var body: some View {
		EmojiPackDetailView(hoarder: emojiHoarder, pack: $pack)
			.overlay(alignment: .bottomLeading) {
				Button {
					dismiss()
				} label: {
					Text("Cancel")
						.font(.title3)
						.padding(5)
				}
				.modifier(glassButtonIfAv())
				.padding(.leading)
				.padding(.bottom, isiPhone ? 0 : 16)
				.tint(.gray)
			}
			.overlay(alignment: .bottomTrailing) {
				Button {
					emojiHoarder.addEmojiPack(pack)
					dismiss()
				} label: {
					Text("Add")
						.font(.title3)
						.bold()
						.padding(5)
				}
				.modifier(glassButtonIfAv())
				.padding(.trailing)
				.padding(.bottom, isiPhone ? 0 : 16)
				.tint(.accentColor)
			}
    }
}

#Preview {
	Color.orange
		.ignoresSafeArea(.all)
		.sheet(isPresented: .constant(true)) {
			EmojiPackImporterView(
				emojiHoarder: EmojiHoarder(localOnly: true, skipIndex: true),
				pack: .constant(.test)
			)
		}
}
