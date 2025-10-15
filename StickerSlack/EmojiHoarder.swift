//
//  EmojiHoarder.swift
//  StickerSlack
//
//  Created by neon443 on 15/10/2025.
//

import Foundation
import SwiftUI
import Combine

class EmojiHoarder: ObservableObject {
	private let endpoint: URL = URL(string: "https://slack.com/api/emoji.list")!
	@Published var kys = ""
}
