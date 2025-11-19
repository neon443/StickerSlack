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
					}
				}
				
				Section {
					Text("")
				}
				
				Section("Debug") {
					NavigationLink {
						TrieTestingView()
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
