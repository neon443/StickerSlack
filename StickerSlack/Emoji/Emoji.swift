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
		self.name = try container.decode(String.self, forKey: .name)
		self.remoteImageURL = try container.decode(URL.self, forKey: .remoteImageURL)
	}
	
	init(
		name: String,
		url: URL,
		id: UUID = UUID()
	) {
		self.id = id
		self.name = name
		self.remoteImageURL = url
	}
	
	static var test: Emoji = Emoji(
		name: "a test slack emoji",
		url: Bundle.main.url(forResource: "image", withExtension: "png")!
	)
	
	static var testLongName: Emoji = Emoji(
		name: "ForEach<Array<String>, String, EmojiRow>: the ID jarjarbinks occurs multiple times within the collection, this will give undefined results!",
		url: Bundle.main.url(forResource: "image", withExtension: "png")!
	)
}
