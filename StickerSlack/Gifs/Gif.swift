//
//  Gif.swift
//  StickerSlack
//
//  Created by neon443 on 06/03/2026.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct Gif: StickerProtocol {
	var id: String
	var name: String
	var typeGlyph: String = "giphy.logo"
	
	var localImageURLString: String {
		let urlString = remoteImageURL.absoluteString
		let split = urlString.split(separator: ".")
		let fileExtension = ".\(split.last ?? "png")"
		
		return GifHoarder.container.path()+name+"."+id+fileExtension
	}
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
	
	func downloadImage() async throws {
		if let data = try? Data(contentsOf: localImageURL),
		   let _ = UIImage(data: data) {
			return
		}
		
		var (data, _) = try await URLSession.shared.data(from: remoteImageURL)
		
		if let uiImage = UIImage(data: data),
		   let cgImage = uiImage.cgImage,
		   !self.localImageURLString.contains(".gif"),
		   cgImage.width < 300 || cgImage.height < 300 {
			data = resize(image: uiImage, to: CGSize(width: 300, height: 300)).pngData()!
		}
		
		try! data.write(to: localImageURL)
		return
	}	
}
