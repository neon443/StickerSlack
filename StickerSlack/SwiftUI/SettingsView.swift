//
//  SettingsView.swift
//  StickerSlack
//
//  Created by neon443 on 18/11/2025.
//

import SwiftUI

struct SettingsView: View {
	@ObservedObject var hoarder: EmojiHoarder
	
	var body: some View {
		NavigationStack {
			List {
				Section {
					VStack(alignment: .leading) {
						Image(systemName: "app.dashed")
							.resizable().scaledToFit()
							.frame(width: 100, height: 100)
							.clipShape(RoundedRectangle(cornerRadius: 24))
							.foregroundStyle(.purple)
							.shadow(color: .purple, radius: 5)
						Text("StickerSlack")
							.font(.title)
							.monospaced()
							.bold()
						HStack(alignment: .center, spacing: 5) {
							Text(Bundle.main.appVersion)
								.bold()
							Text(Bundle.main.appBuild)
								.foregroundStyle(.gray)
						}
					}
				}
				
				Section {
					Text("\(hoarder.emojis.count) total Emoji")
					Text("\(hoarder.downloadedEmojis.count) downloaded Emoji")
					NavigationLink {
						List {
							ForEach(hoarder.generateLetterStats(), id: \.self) { stat in
								Text("\(stat.count) Emoji starting with \(stat.char)")
							}
						}
					} label: {
						Label("Letter Stats", systemImage: "textformat")
					}
				}
				
				Button("Show Welcome", systemImage: "arrow.trianglehead.clockwise") {
					hoarder.setShowWelcome(to: true)
				}
				
				Section("Debug") {
					NavigationLink {
						TrieTestingView(hoarder: hoarder)
					} label: {
						Label("Tree", systemImage: "tree")
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
