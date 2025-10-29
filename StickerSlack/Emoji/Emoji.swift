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
	var uiID: UUID = UUID()
	var name: String
	var localImageURL: URL {
		let urlString = remoteImageURL.absoluteString
		let split = urlString.split(separator: ".")
		let fileExtension = ".\(split.last ?? "png")"
		return EmojiHoarder.container.appendingPathComponent(id.uuidString+fileExtension, conformingTo: .image)
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
		self.name = try container.decode(String.self, forKey: .name)
		self.remoteImageURL = try container.decode(URL.self, forKey: .remoteImageURL)
	}
	
	init(
		apiEmoji: ApiEmoji,
		id: UUID = UUID()
	) {
		self.id = id
		self.name = apiEmoji.name
		self.remoteImageURL = apiEmoji.url
	}
	
	func downloadImage() async throws -> UIImage {
		if let data = try? Data(contentsOf: localImageURL),
			let uiimage = UIImage(data: data) {
			return uiimage
		}
		let (data, _) = try await URLSession.shared.data(from: remoteImageURL)
		try! data.write(to: localImageURL)
		return UIImage(data: data)!
	}
	
	func deleteImage() {
		try? FileManager.default.removeItem(at: localImageURL)
	}
	
	mutating func refresh() {
		withAnimation { self.uiID = UUID() }
	}
}
