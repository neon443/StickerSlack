//
//  Gif.swift
//  StickerSlack
//
//  Created by neon443 on 06/03/2026.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

@MainActor
struct Gif: StickerProtocol {
	var id: String
	var name: String
	var typeGlyph: String = "giphy.logo"
	var remoteImageURL: URL
	
	var giphyImages: GiphyImages?
	
	//	enum CodingKeys: String, CodingKey {
	//
	//	}
	
	init(
		name: String,
		url: URL,
		giphyImages: GiphyImages?,
		id: String = UUID().uuidString
	) {
		self.id = id
		self.name = name
		self.giphyImages = giphyImages
		self.remoteImageURL = url
	}
}
