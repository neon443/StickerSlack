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
	var id: UUID
	var name: String
	var localImageURLString: String {
		let urlString = remoteImageURL.absoluteString
		let split = urlString.split(separator: ".")
		let fileExtension = ".\(split.last ?? "png")"
			
		return EmojiHoarder.container.appendingPathComponent("gifs", conformingTo: .directory).absoluteString+id.uuidString+fileExtension
	}
	var remoteImageURL: URL
	
//	enum CodingKeys: String, CodingKey {
//		
//	}
	
	init(
		name: String,
		url: URL,
		id: UUID = UUID()
	) {
		self.id = id
		self.name = name
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
	
	static var test: Gif = Gif(
		name: "doesheknow",
		url: URL(string: "https://media1.tenor.com/m/FN9udnZmQU8AAAAd/does-he-know-batman.gif")!
	)
}
