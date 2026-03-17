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

protocol Hoarder: ObservableObject {
	static var container: URL { get }
	var endpoint: URL { get }
	var downloadedStickers: Set<String> { get set }
	var encoder: JSONEncoder { get }
	var decoder: JSONDecoder { get }
	
	func download(emoji: any StickerProtocol, skipStoreIndex: Bool) async
	func delete(emoji: any StickerProtocol, skipStoreIndex: Bool)
}

extension Hoarder {
	var encoder: JSONEncoder { JSONEncoder() }
	var decoder: JSONDecoder { JSONDecoder() }
}
