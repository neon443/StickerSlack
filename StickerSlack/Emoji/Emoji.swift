//
//  Emoji.swift
//  StickerSlack
//
//  Created by neon443 on 17/10/2025.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

struct Emoji: Codable, Identifiable, Hashable {
	var id: UUID
	var uiID: UUID
	var name: String
	var localImageURL: URL
	var remoteImageURL: URL
	
	var isLocal: Bool {
		return (try? Data(contentsOf: localImageURL)) != nil
	}
	
	var image: UIImage?
	
	enum CodingKeys: String, CodingKey {
		case id = "id"
		case name = "name"
		case localImageURL = "localImageURL"
		case remoteImageURL = "remoteImageURL"
	}
	
	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(UUID.self, forKey: .id)
		self.uiID = UUID()
		self.name = try container.decode(String.self, forKey: .name)
		self.localImageURL = try container.decode(URL.self, forKey: .localImageURL)
		self.remoteImageURL = try container.decode(URL.self, forKey: .remoteImageURL)
		
		if let data = try? Data(contentsOf: localImageURL),
		   let img = UIImage(data: data) {
			self.image = img
		} else {
			self.image = nil
		}
	}
	
	init(
		apiEmoji: ApiEmoji,
		id: UUID = UUID()
	) {
		self.id = id
		self.uiID = id
		self.name = apiEmoji.name
		self.remoteImageURL = apiEmoji.url
		
		let fileExtension = String(apiEmoji.urlString.split(separator: ".").last ?? "png")
		self.localImageURL = EmojiHoarder.container.appendingPathComponent(id.uuidString+"."+fileExtension, conformingTo: .image)

//		Task { [weak self] in
//			let (data, response) = try await URLSession.shared.data(from: apiEmoji.url)
//			self.image = UIImage(data: data)
//		}
//		let image = try! Data(contentsOf: apiEmoji.url)
//		try! image.write(to: localImageURL)
//		self.image = UIImage(data: image) ?? UIImage()
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
		self.uiID = UUID()
	}
}
