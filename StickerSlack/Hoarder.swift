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
	
	nonisolated func buildDownloadedStickers(for stickerType: String) async {
		if let data = UserDefaults.standard.data(forKey: "downloaded\(stickerType)"),
		   let decoded = try? await decoder.decode(Set<String>.self, from: data) {
			await MainActor.run {
				downloadedStickers = decoded
			}
		} else {
			var newSet: Set<String> = []
			let url = await BaseHoarder.library.appendingPathComponent(stickerType, conformingTo: .directory)
			if let files = try? FileManager.default.contentsOfDirectory(atPath: url.path()) {
				for file in files {
					let name = String(file.split(separator: ".")[0])
					newSet.insert(name)
				}
			}
			newSet.remove("DS_Store")
			let immutable = newSet
			await MainActor.run {
				self.downloadedStickers = []
				self.downloadedStickers = immutable
			}
			return
		}
	}
	
	init() { }
}
