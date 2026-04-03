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
	var id: String
	var name: String
	var typeGlyph: String = "slack.logo"
	var localImageURLString: String {
		let urlString = remoteImageURL.absoluteString
		let split = urlString.split(separator: ".")
		let fileExtension = ".\(split.last ?? "png")"
		return EmojiHoarder.container.absoluteString+id+fileExtension
	}
	var remoteImageURL: URL
	
	enum CodingKeys: String, CodingKey {
		case id = "id"
		case name = "name"
		case remoteImageURL = "imageUrl"
	}
	
	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		self.name = try container.decode(String.self, forKey: .name)
		self.remoteImageURL = try container.decode(URL.self, forKey: .remoteImageURL)
	}
	
	init(
		name: String,
		url: URL,
		id: String = UUID().uuidString
	) {
		self.id = id
		self.name = name
		self.remoteImageURL = url
	}
}
