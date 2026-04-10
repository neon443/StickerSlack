//
//  StickerSlackApp.swift
//  StickerSlack
//
//  Created by neon443 on 15/10/2025.
//

import SwiftUI

@main
struct StickerSlackApp: App {
	var body: some Scene {
		WindowGroup {
			ContentView()
				.onOpenURL { url in
					print(EmojiPack(fromShareLink: url))
				}
		}
	}
}
