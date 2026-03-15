//
//  Hoarder.swift
//  StickerSlack
//
//  Created by neon443 on 10/03/2026.
//

import Foundation
import SwiftUI
import Combine
import UniformTypeIdentifiers

protocol Hoarder {
	static var container: URL { get }
	var endpoint: URL { get }
	var encoder: JSONEncoder { get }
	var decoder: JSONDecoder { get }
	
	func download(emoji: Emoji, skipStoreIndex: Bool) async
	func delete(emoji: Emoji, skipStoreIndex: Bool)
}

extension Hoarder {
	var encoder: JSONEncoder { JSONEncoder() }
	var decoder: JSONDecoder { JSONDecoder() }
}
