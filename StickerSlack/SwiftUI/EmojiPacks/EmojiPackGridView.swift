//
//  EmojiPackGridView.swift
//  StickerSlack
//
//  Created by neon443 on 30/04/2026.
//

import SwiftUI

struct EmojiPackGridView: View {
	@ObservedObject var hoarder: EmojiHoarder
	@Binding var pack: EmojiPack
	
	@Binding var edit: Bool
	@State var initDate: Date = .now
	
	@State var showAdder: Bool = false
	@State var searchTerm: String = ""

	@State var showNotFoundAlert: Bool = false
	
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
    }
}

#Preview {
	EmojiPackGridView(
		hoarder: EmojiHoarder(),
		pack: .constant(.test),
		edit: .constant(Bool.random())
	)
}
