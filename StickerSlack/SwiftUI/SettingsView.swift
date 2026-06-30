//
//  SettingsView.swift
//  StickerSlack
//
//  Created by neon443 on 18/11/2025.
//

import SwiftUI
import Haptics

struct SettingsView: View {
	@ObservedObject var hoarder: EmojiHoarder
	
	@Environment(\.colorScheme) var colorScheme
	var isDark: Bool {
		return colorScheme == .dark
	}
	var body: some View {
		NavigationView2 {
			List {
				Section {
					HStack {
						Image("icon")
							.resizable().scaledToFit()
							.frame(width: 100, height: 100)
							.clipShape(RoundedRectangle(cornerRadius: 24))
							.foregroundStyle(Color.accentColor)
							.shadow(color: isDark ? .black : .accentColor, radius: 5)
							.padding(.leading, -1)
							.padding(.trailing, 10)
						VStack(alignment: .leading) {
							Text("StickerSlack")
								.font(.title2.monospaced().bold())
							HStack(alignment: .center, spacing: 5) {
								Text(Bundle.main.appVersion)
									.bold()
									.font(.subheadline)
								Text(Bundle.main.appBuild)
									.foregroundStyle(.gray)
									.font(.subheadline)
							}
						}
					}
				}
				
				Section("Stats") {
					Text("\(hoarder.emojis.count) total Emoji")
					Text("\(hoarder.downloadedStickers.count) downloaded Emoji")
					if hoarder.downloadedStickers.count == hoarder.emojis.count {
						Text("🎉")
							.font(.largeTitle)
							.onTapGesture {
								Haptic.rigid.trigger()
							}
					}
//					NavigationLink {
//						List {
//							Picker(selection: $hoarder.letterStatsSorting.by) {
//								ForEach(EmojiHoarder.SortLetterStatsBy.allCases, id: \.self) { sortType in
//									Text(sortType.rawValue).tag(sortType)
//								}
//							} label: {
//								Label("Sort by", systemImage: "arrow.up.arrow.down")
//							}
//							.onChange(of: hoarder.letterStatsSorting.by) { _ in
//								hoarder.sortLetterStats(by: hoarder.letterStatsSorting)
//							}
//							
//							Picker(selection: $hoarder.letterStatsSorting.ascending) {
//									Text("Ascending").tag(true)
//									Text("Descending").tag(false)
//							} label: {
//								Label("Order", systemImage: "greaterthan")
//							}
//							.onChange(of: hoarder.letterStatsSorting.ascending) { _ in
//								hoarder.sortLetterStats(by: hoarder.letterStatsSorting)
//							}
//							
//							ForEach(hoarder.letterStats, id: \.self) { stat in
//								HStack {
//									Text("\(stat.char)")
//									Spacer()
//									Text("\(stat.count)")
//								}
//							}
//						}
//						.onAppear {
//							hoarder.generateLetterStats()
//						}
//					} label: {
//						Label("Letter Stats", systemImage: "textformat")
//					}
				}
				
				Button("Show Welcome", systemImage: "arrow.trianglehead.clockwise") {
					hoarder.setShowWelcome(to: true)
				}
				
				Section("Use with Caution") {
					Button("Download all", systemImage: "square.and.arrow.down.on.square", role: .destructive) {
						Task {
							await hoarder.downloadAllStickers()
						}
					}
					.foregroundStyle(.red)
					Button("Delete all", systemImage: "trash.circle", role: .destructive) {
						Task {
							await hoarder.deleteAllStickers()
						}
					}
					.foregroundStyle(.red)
				}
				
				Section("Debug") {
					NavigationLink {
						JumboMojiTestView(hoarder: hoarder)
					} label: {
						Label("jumbomoji search", systemImage: "text.page.badge.magnifyingglass")
					}
					NavigationLink {
						EmojiCollectionViewRepresentable(
							hoarder: hoarder,
							items: [
								"btn-3kh0-1",
								"btn-3kh0-2",
								"btn-3kh0-3",
								"btn-antinft-1",
								"btn-antinft-2",
								"btn-antinft-3",
								"btn-bsky-1",
								"btn-bsky-2",
								"btn-bsky-3",
								"btn-gideon-1",
								"btn-gideon-2",
								"btn-gideon-3",
								"btn-macos-1",
								"btn-macos-2",
								"btn-macos-3",
								"btn-microhate-1",
								"btn-microhate-2",
								"btn-microhate-3"
							],
							width: 3,
							style: .jumboMoji
						)
					} label: {
						Label("jumbomoji", systemImage: "square.split.2x2")
					}
					NavigationLink {
						EmojiCollectionViewRepresentable(
							hoarder: hoarder,
							items: hoarder.emojis.prefix(10000).map { $0.name },
							width: 10,
							style: .jumboMoji
						)
					} label: {
						Label("grid view", systemImage: "square.grid.2x2.fill")
					}
					
					Button("Refresh", systemImage: "arrow.clockwise", role: .destructive) {
						hoarder.startLoading(localOnly: false, skipIndex: false)
					}
					
					NavigationLink {
						TrieTestingView(hoarder: hoarder)
					} label: {
						Label("search testing", systemImage: "magnifyingglass")
					}
					
					NavigationLink {
						Text("<SwiftUI Grids>")
							.foregroundStyle(.red)
							.font(.title)
						EmojiPackManager(hoarder: hoarder, useSwiftUIGrid: true)
					} label: {
						Label("packs wip", systemImage: "square.stack")
					}
					
					Button("Reindex", systemImage: "list.bullet.clipboard", role: .destructive) {
						hoarder.resetAllIndexes()
						Task {
							await hoarder.buildTrie()
						}
					}
					.foregroundStyle(.red)
				}
				//			Section(content: <#T##() -> View#>, header: <#T##() -> View#>, footer: <#T##() -> View#>)
			}
		}
    }
}

#Preview {
    SettingsView(hoarder: EmojiHoarder(localOnly: true, skipIndex: true))
}
