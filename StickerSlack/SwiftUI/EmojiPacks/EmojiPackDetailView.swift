//
//  EmojiPackView.swift
//  StickerSlack
//
//  Created by neon443 on 01/12/2025.
//

import SwiftUI
import Haptics

struct EmojiPackDetailView: View {
	@ObservedObject var hoarder: EmojiHoarder
	@Binding var pack: EmojiPack
	
	@State var edit: Bool = false
	@State var editName: Bool = false
	@State var editDescription: Bool = false
		
	@State var downloading: Bool = false
	
	@State var showAdder: Bool = false
	@State var showShare: Bool = false
	
	@State var useSwiftUIGrid: Bool = false
	
	var allDownloaded: Bool {
		pack.allDownloaded(in: hoarder)
	}
	var downloadedFraction: Double {
		pack.downloadedFraction(in: hoarder)
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
					EmptyCollectionView(
						title: "No Emoji",
						details: "Add emojis to this pack by editing it using the pencil button in the toolbar.",
						systemImage: "exclamationmark.triangle.fill"
					)
				}
				
				if useSwiftUIGrid {
					EmojiPackGridView(
						hoarder: hoarder,
						pack: $pack,
						edit: $edit
					)
				} else {
					EmojiCollectionViewRepresentable(
						hoarder: hoarder,
						items: pack.items,
						width: 75,
						style: .full,
						edit: edit,
						onRemoveSUI: { pack.remove($0) }
					)
				}
				
				if !pack.items.isEmpty {
					Text("\(pack.items.count) Emoji\(pack.items.count.plural)")
						.bold()
						.multilineTextAlignment(.center)
						.shadow(radius: 5)
						.padding(.bottom)
				}
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
					.tint(edit ? Color.accentColor : .primary)
				}
				ToolbarItem(placement: .topBarLeading) {
					if edit {
						Button("", systemImage: "plus") {
							showAdder.toggle()
						}
						.sheet(isPresented: $showAdder) {
							NavigationView2 {
								SearchView(
									hoarder: hoarder,
									fromPackEditor: true,
									callback: {
										pack.add($0)
										Haptic.success.trigger()
										showAdder.toggle()
									}
								)
								.navigationTitle("Search Emojis")
								.navigationBarTitleDisplayMode(.inline)
								.toolbar {
									Button("", systemImage: "checkmark") {
										showAdder.toggle()
									}
								}
							}
							.modifier(presentationHalfAndFullIfAv())
						}
					}
				}
				
				ToolbarItem(placement: .topBarTrailing) {
					if downloading {
						ProgressView()
							.onChange(of: allDownloaded) { newValue in
								if newValue == true {
									downloading = false
								}
							}
					} else {
						Button(
							"",
							systemImage: allDownloaded ? "checkmark" : "arrow.down"
						) {
							if !allDownloaded {
								downloading = true
							}
							Task {
								if allDownloaded {
									await pack.deleteAll(hoarder: hoarder)
								} else {
									await pack.downloadAll(hoarder: hoarder)
								}
							}
						}
						.disabled(pack.items.isEmpty)
						.tint(allDownloaded ? .red : .accentColor)
					}
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
