//
//  EmojiPackView.swift
//  StickerSlack
//
//  Created by neon443 on 01/12/2025.
//

import SwiftUI

struct EmojiPackDetailView: View {
	@ObservedObject var hoarder: EmojiHoarder
	@Binding var pack: EmojiPack
	
	@State var edit: Bool = false
	@State var editName: Bool = false
	@State var editDescription: Bool = false
		
	@State var showShare: Bool = false
	
	@State var useSwiftUIGrid: Bool = false
	
	var allDownloaded: Bool {
		let date = Date.now
		let result = Set(pack.items).isSubset(of: hoarder.downloadedStickers)
//		print("hit \(Date.now.timeIntervalSince(date)) \(UUID())")
		return result
	}
	
	var body: some View {
		NavigationView2 {
			VStack {
				Button() {
					editName.toggle()
				} label: {
					Text(pack.name.isEmpty ? "Name" : pack.name)
						.bold()
						.foregroundStyle(edit ? Color.accentColor : .primary)
						.font(.title)
				}
				.disabled(!edit)
				.alert("Edit Name", isPresented: $editName) {
					TextField("", text: $pack.name)
				}
				
				Button() {
					editDescription.toggle()
				} label: {
					Text(pack.description.isEmpty ? "Description" : pack.description)
						.foregroundStyle(edit ? Color.accentColor : .primary)
				}
				.disabled(!edit)
				.alert("Edit Description", isPresented: $editDescription) {
					TextField("", text: $pack.description)
				}
				
				if pack.items.isEmpty {
					EmptyEmojiPackView()
				}
				
				if useSwiftUIGrid {
					EmojiPackGridView(
						hoarder: hoarder,
						pack: $pack,
						edit: $edit
					)
				} else {
					EmojiCollectionView(
						hoarder: hoarder,
						items: pack.items,
						pack: pack,
						width: 75,
						style: .full,
						edit: edit,
						onRemoveSUI: { pack.remove($0) }
					)
				}
				
				Text("\(pack.items.count) Emoji\(pack.items.count.plural)")
					.bold()
					.multilineTextAlignment(.center)
					.shadow(radius: 5)
					.padding(.bottom)
			}
			.transition(.scale)
			.navigationTitle(edit ? "Editing" : "Pack Details")
			.navigationBarTitleDisplayMode(.inline)
			.onDisappear {
				hoarder.saveEmojiPacks()
			}
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button(
						"",
						systemImage: edit ? "checkmark" : "pencil"
					) {
						withAnimation(.spring) { edit.toggle() }
					}
					.modifier(glassButtonIfAv(edit))
					.tint(edit ? Color.accentColor : .primary)
				}
				ToolbarItem(placement: .topBarTrailing) {
					Button("", systemImage: allDownloaded ? "checkmark" : "arrow.down") {
						Task {
							if allDownloaded {
								await pack.deleteAll(hoarder: hoarder)
							} else {
								await pack.downloadAll(hoarder: hoarder)
							}
						}
					}
					.tint(allDownloaded ? .red : .accentColor)
				}
				ToolbarItem(placement: .topBarTrailing) {
					if #available(iOS 16, *) {
						ShareLink(item: pack.shareLink()) {
							Image(systemName: "square.and.arrow.up")
						}
					} else {
						Button("", systemImage: "square.and.arrow.up") {
							showShare.toggle()
						}
						.sheet(isPresented: $showShare) {
							ShareSheet(activityItems: [pack.shareLink()])
						}
					}
				}
			}
		}
	}
}

@available(iOS 17, *)
#Preview {
	@Previewable @State var hoarder = EmojiHoarder(localOnly: true, skipIndex: false)
	@Previewable @State var pack: EmojiPack = .test
	EmojiPackDetailView(
		hoarder: hoarder,
		pack: $pack
	)
}
