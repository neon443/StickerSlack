//
//  Emoji.swift
//  StickerSlack
//
//  Created by neon443 on 17/10/2025.
//

import Foundation
import UIKit
import SwiftUI
import Messages
import UniformTypeIdentifiers

struct Emoji: Codable, Identifiable, Hashable {
	var id: UUID
	var uiID: UUID
	var name: String
	var localImageURLString: String {
		let urlString = remoteImageURL.absoluteString
		let split = urlString.split(separator: ".")
		let fileExtension = ".\(split.last ?? "png")"
		return EmojiHoarder.container.absoluteString+id.uuidString+fileExtension
	}
	var localImageURL: URL {
		return URL(string: localImageURLString)!
	}
	var remoteImageURL: URL
	
	var isLocal: Bool {
		return (try? Data(contentsOf: localImageURL)) != nil
	}
	
	var sticker: MSSticker? {
		guard isLocal else {
			return nil
		}
		return try? MSSticker(contentsOfFileURL: localImageURL, localizedDescription: name)
	}
	
	var image: UIImage? {
		if let data = try? Data(contentsOf: localImageURL),
		   let img = UIImage(data: data) {
			return img
		} else {
			return nil
		}
	}
	
	enum CodingKeys: String, CodingKey {
		case id = "id"
		case name = "name"
		case remoteImageURL = "imageUrl"
	}
	
	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(UUID.self, forKey: .id)
		self.uiID = id
		self.name = try container.decode(String.self, forKey: .name)
		self.remoteImageURL = try container.decode(URL.self, forKey: .remoteImageURL)
	}
	
	init(
		name: String,
		url: URL,
		id: UUID = UUID()
	) {
		self.id = id
		self.uiID = id
		self.name = name
		self.remoteImageURL = url
	}
	
	nonisolated
	func downloadImage() async throws {
		if let data = try? await Data(contentsOf: localImageURL),
			let _ = UIImage(data: data) {
			return
		}
		let (data, _) = try await URLSession.shared.data(from: remoteImageURL)
		try! await data.write(to: localImageURL)
		return
	}
	
	func deleteImage() {
		try? FileManager.default.removeItem(at: localImageURL)
		return
	}
	
	@MainActor
	mutating func refresh() {
		withAnimation { self.uiID = UUID() }
	}
	
	static var test: Emoji = Emoji(
		name: "s?",
		url: URL(string: "https://neon443.github.io/images/fav.ico")!
	)
}
