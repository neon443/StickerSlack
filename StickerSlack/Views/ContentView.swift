//
//  ContentView.swift
//  StickerSlack
//
//  Created by neon443 on 15/10/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
		TabView {
			Text("hi")
				.tabItem {
					Label("home", systemImage: "house")
				}
		}
    }
}

#Preview {
    ContentView()
}
