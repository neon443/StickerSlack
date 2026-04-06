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
			var newDownloadedStickers: Set<String> = []
			if let files = try? await FileManager.default.contentsOfDirectory(atPath: BaseHoarder.library.appendingPathComponent(stickerType, conformingTo: .directory).path()) {
				for file in files {
					let name = String(file.split(separator: ".")[0])
					newDownloadedStickers.insert(name)
				}
			}
			newDownloadedStickers.remove("DS_Store")
			await MainActor.run {
				downloadedStickers = []
				downloadedStickers = newDownloadedStickers
			}
			return
		}
	}
	
	init() { }
}
