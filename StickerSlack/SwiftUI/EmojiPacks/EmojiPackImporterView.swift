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
	
    var body: some View {
		EmojiPackDetailView(hoarder: emojiHoarder, pack: $pack)
			.overlay(alignment: .bottomLeading) {
				Button {
					withAnimation {
						emojiHoarder.emojiPacks.append(pack)
						dismiss()
					}
				} label: {
					Text("Cancel")
						.font(.title3)
						.padding(5)
				}
				.modifier(glassButtonIfAv())
				.padding(.leading)
				.tint(.gray)
			}
			.overlay(alignment: .bottomTrailing) {
				Button {
					withAnimation {
						emojiHoarder.emojiPacks.append(pack)
						dismiss()
					}
				} label: {
					Text("Add")
						.font(.title3)
						.bold()
						.padding(5)
				}
				.modifier(glassButtonIfAv())
				.padding(.trailing)
				.tint(.purple)
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
