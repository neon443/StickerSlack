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

struct Emoji: StickerProtocol {
	var id: UUID
	var uiID: UUID
	var name: String
	var localImageURLString: String {
		let urlString = remoteImageURL.absoluteString
		let split = urlString.split(separator: ".")
		let fileExtension = ".\(split.last ?? "png")"
		return EmojiHoarder.container.absoluteString+id.uuidString+fileExtension
	}
	var remoteImageURL: URL
	
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
		
		var (data, _) = try await URLSession.shared.data(from: remoteImageURL)
		
		if let uiImage = UIImage(data: data),
		   let cgImage = uiImage.cgImage,
		   await !self.localImageURLString.contains(".gif"),
		   cgImage.width < 300 || cgImage.height < 300 {
			data = await resize(image: uiImage, to: CGSize(width: 300, height: 300)).pngData()!
		}
		try! await data.write(to: localImageURL)
		return
	}
	
	@MainActor
	mutating func refresh() {
		withAnimation { self.uiID = UUID() }
	}
	
	static var test: Emoji = Emoji(
		name: "s?",
		url: URL(string: "https://files.catbox.moe/d8go4n.png")!
	)
}
