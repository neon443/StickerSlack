//
//  StickerType.swift
//  StickerSlack
//
//  Created by neon443 on 06/03/2026.
//

import Foundation

enum StickerType: CustomStringConvertible, CaseIterable, Identifiable {
	case slackEmoji
	case giphyGifs
	
	var id: String { self.description }
	
	var description: String {
		switch self {
		case .slackEmoji:
			return "Slack Emoji"
		case .giphyGifs:
			return "Giphy GIFs"
		}
	}
}
