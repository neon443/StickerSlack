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
	@State var initDate: Date = .now
	
	@State var showAdder: Bool = false
	@State var searchTerm: String = ""
	
	@State var showShare: Bool = false
	
	@State var showNotFoundAlert: Bool = false
	
	var allDownloaded: Bool {
		let date = Date.now
		let result = Set(pack.items).isSubset(of: hoarder.downloadedStickers)
//		print("hit \(Date.now.timeIntervalSince(date)) \(UUID())")
		return result
	}
	
	var minColWidth: CGFloat { 75 }
	var spacing: CGFloat { 10 }
	var col: GridItem {
		GridItem(
			.flexible(minimum: minColWidth, maximum: 100),
			spacing: spacing,
			alignment: .center
		)
	}
	@Environment(\.dismiss) var dismiss
	
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
				
				EmojiCollectionView(
					hoarder: hoarder,
					items: pack.items,
					pack: pack,
					width: 75,
					style: .full
				)
				
				GeometryReader { geo in
					let columns: Int = max(1, Int((geo.size.width - 2*spacing) / (minColWidth + spacing)))
					let layout = Array(repeating: col, count: columns)
					ScrollView {
						LazyVGrid(columns: layout, spacing: spacing) {
							ForEach(pack.items, id: \.self) { name in
								TimelineView(.animation) { tl in
									Group {
										VStack {
											if let emoji = hoarder.trie.dict[name] {
												StickerPreview(sticker: emoji)
												Text(emoji.UIName)
													.multilineTextAlignment(.center)
													.font(.caption)
											} else {
												Image(systemName: "questionmark.circle.dashed")
													.resizable().scaledToFit()
													.foregroundStyle(.gray.opacity(0.5))
													.overlay(alignment: .topTrailing) {
														Button {
															showNotFoundAlert.toggle()
														} label: {
															Image(systemName: "info")
																.font(.title3.bold())
														}
													}
												Text(name)
													.multilineTextAlignment(.center)
													.font(.caption)
											}
											Spacer()
										}
										.alert("This emoji was not found", isPresented: $showNotFoundAlert) {
											Button("OK") {
												showNotFoundAlert.toggle()
											}
										} message: {
											Text("Try reopening the app with an Internet connection to refresh the emoji database.")
										}
									}
									.overlay(alignment: .topLeading) {
										if edit {
											Button(role: .destructive) {
												withAnimation(.spring) {
													pack.remove(name)
												}
											} label: {
												Image(systemName: "minus.circle.fill")
													.resizable().scaledToFit()
											}
											.frame(maxWidth: 25)
											.padding(-10)
										}
									}
									.rotationEffect(
										.degrees(
											edit ? sin(initDate.timeIntervalSinceNow*20)*4 : 0
										)
									)
								}
							}
							if edit {
								Button() {
									showAdder.toggle()
								} label: {
									VStack {
										Image(systemName: "plus.square.dashed")
											.resizable().scaledToFit()
											.foregroundStyle(.green.opacity(0.5))
										Text("Add")
											.multilineTextAlignment(.center)
											.font(.caption)
											.foregroundStyle(.green.opacity(0.5))
										Spacer()
									}
								}
								.sheet(isPresented: $showAdder) {
									NavigationView2 {
										SearchView(hoarder: hoarder, fromPackEditor: true) { selection in
											withAnimation(.spring) {
												pack.add(selection.name)
											}
										}
										.navigationTitle("Search Emojis")
										.navigationBarTitleDisplayMode(.inline)
										.modifier(presentationHalfAndFullIfAv())
										.toolbar {
											Button("", systemImage: "xmark") {
												showAdder.toggle()
											}
										}
									}
								}
							}
						}
						.animation(.spring, value: pack.items)
						.padding()
					}
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
