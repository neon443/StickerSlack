//
//  SettingsView.swift
//  StickerSlack
//
//  Created by neon443 on 18/11/2025.
//

import SwiftUI

struct SettingsView: View {
	@ObservedObject var hoarder: EmojiHoarder
	
	@Environment(\.colorScheme) var colorScheme
	var isDark: Bool {
		return colorScheme == .dark
	}
	var body: some View {
		NavigationStack {
			List {
				Section {
					HStack {
						Image(isDark ? "icon-dark" : "icon")
							.resizable().scaledToFit()
							.frame(width: 100, height: 100)
							.clipShape(RoundedRectangle(cornerRadius: 24))
							.foregroundStyle(.purple)
							.shadow(color: isDark ? .white : .purple, radius: 2)
							.padding(.trailing, 10)
						VStack(alignment: .leading) {
							Text("StickerSlack")
								.font(.title2)
								.monospaced()
								.bold()
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
				
				Section {
					Text("\(hoarder.emojis.count) total Emoji")
					Text("\(hoarder.downloadedEmojis.count) downloaded Emoji")
					if hoarder.downloadedEmojis.count == hoarder.emojis.count {
						Text("🎉")
							.font(.largeTitle)
					}
					NavigationLink {
						List {
							Picker(selection: $hoarder.letterStatsSorting.by) {
								ForEach(EmojiHoarder.SortLetterStatsBy.allCases, id: \.self) { sortType in
									Text(sortType.rawValue).tag(sortType)
								}
							} label: {
								Label("Sort by", systemImage: "arrow.up.arrow.down")
							}
							.onChange(of: hoarder.letterStatsSorting.by) { _ in
								hoarder.sortLetterStats(by: hoarder.letterStatsSorting)
							}
							
							Picker(selection: $hoarder.letterStatsSorting.ascending) {
									Text("Ascending").tag(true)
									Text("Descending").tag(false)
							} label: {
								Label("Order", systemImage: "greaterthan")
							}
							.onChange(of: hoarder.letterStatsSorting.ascending) { _ in
								hoarder.sortLetterStats(by: hoarder.letterStatsSorting)
							}
							
							ForEach(hoarder.letterStats, id: \.self) { stat in
								HStack {
									Text("\(stat.char)")
									Spacer()
									Text("\(stat.count)")
								}
							}
						}
					} label: {
						Label("Letter Stats", systemImage: "textformat")
					}
				}
				
				Button("Show Welcome", systemImage: "arrow.trianglehead.clockwise") {
					hoarder.setShowWelcome(to: true)
				}
				
				Section("Use with Caution") {
					Button("download all", role: .destructive) {
						hoarder.downloadAllStickers()
					}
					Button("delete all", role: .destructive) {
						hoarder.deleteAllStickers()
					}
				}
				
				Section("Debug") {
					NavigationLink {
						TrieTestingView(hoarder: hoarder)
					} label: {
						Label("Tree", systemImage: "tree")
					}
					
					Button(role: .destructive) {
						hoarder.resetAllIndexes()
						hoarder.buildTrie()
					} label: {
						Label("Reindex", systemImage: "list.bullet.clipboard.fill")
					}
				}
				//			Section(content: <#T##() -> View#>, header: <#T##() -> View#>, footer: <#T##() -> View#>)
			}
		}
    }
}

#Preview {
    SettingsView(hoarder: EmojiHoarder(localOnly: true, skipIndex: true))
}
