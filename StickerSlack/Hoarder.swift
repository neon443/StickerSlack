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
import Haptics

protocol Hoarder: ObservableObject {
	static var library: URL { get }
	var downloadedStickers: Set<String> { get set }
	var encoder: JSONEncoder { get }
	var decoder: JSONDecoder { get }
	
	func download(emoji: any StickerProtocol, skipStoreIndex: Bool) async
	func delete(emoji: any StickerProtocol, skipStoreIndex: Bool)
}

class BaseHoarder: Hoarder {
	
	static let library: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.neon443.StickerSlack")!.appendingPathComponent("Library", conformingTo: .directory)
	
	@Published var downloadedStickers: Set<String> = []

	var encoder: JSONEncoder = JSONEncoder()
	var decoder: JSONDecoder = JSONDecoder()

	func download(emoji: any StickerProtocol, skipStoreIndex: Bool) async {
		try? await emoji.downloadImage()
		await MainActor.run {
			Haptic.success.trigger()
		}
	}
	
	func delete(emoji: any StickerProtocol, skipStoreIndex: Bool) {
		emoji.deleteImage()
	}
	
	init() { }
}
