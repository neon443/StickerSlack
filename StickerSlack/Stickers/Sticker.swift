//
//  Sticker.swift
//  StickerSlack
//
//  Created by neon443 on 06/03/2026.
//

import Foundation
import Messages

extension StickerProtocol {
	var localImageURLString: String {
		let containerPath: String
		switch type {
		case .slackEmoji:
			containerPath = EmojiHoarder.container.safePath
		case .giphyGifs:
			containerPath = GifHoarder.container.safePath
		}
		let urlString = remoteImageURL.absoluteString
		let split = urlString.split(separator: ".")
		let fileExtension = ".\(split.last!)"
		return containerPath+name+"."+id+fileExtension
	}
	
	var localImageURL: URL {
		if #available(iOS 16, *) {
			return URL(filePath: localImageURLString)
		} else {
			return URL(fileURLWithPath: localImageURLString)
		}
	}
	
	var msSticker: MSSticker? {
		guard FileManager.default.fileExists(atPath: localImageURLString) else {
			return nil
		}
		return try? MSSticker(contentsOfFileURL: localImageURL, localizedDescription: name)
	}
	
	nonisolated var isLocal: Bool {
		return FileManager.default.fileExists(atPath: localImageURLString)
	}
	
	nonisolated func data() async -> Data? {
		var result: (data: Data, response: URLResponse)
		do {
			result = try await URLSession.shared.data(from: isLocal ? localImageURL : remoteImageURL)
		} catch {
			print(error.localizedDescription)
			return nil
		}
		return result.data
	}
	
	nonisolated func image() async -> UIImage? {
		guard let data = await data() else { return nil }
		return UIImage(data: data)
	}
	
	var image: UIImage? {
		if FileManager.default.fileExists(atPath: localImageURLString),
		   let data = try? Data(contentsOf: localImageURL),
		   let img = UIImage(data: data) {
			return img
		} else {
			return nil
		}
	}
	
	nonisolated var type: StickerType {
		let typeOfSelf = Swift.type(of: self)
		if typeOfSelf == Emoji.self {
			return .slackEmoji
		} else if typeOfSelf == Gif.self {
			return .giphyGifs
		} else {
			fatalError("unrecognised sticker type get crashed lmfao")
		}
	}
	
	nonisolated
	func downloadImage() async throws {
		if let data = try? await Data(contentsOf: localImageURL),
		   let _ = UIImage(data: data) {
			return
		}
		
		var (data, _) = try await URLSession.shared.data(from: remoteImageURL)
		
		let targetSize = CGSize(width: 100, height: 100)
		if let uiImage = UIImage(data: data),
		   await localImageURLString.suffix(4) != ".gif" {
			data = await resize(image: uiImage, to: targetSize).pngData()!
		}
		
		try! await data.write(to: localImageURL)
	}
	
	func deleteImage() {
		try? FileManager.default.removeItem(at: localImageURL)
		return
	}
	
	nonisolated func resize(image: UIImage, to targetSize: CGSize) async -> UIImage {
		let renderer = UIGraphicsImageRenderer(size: targetSize)
		let resizedImage = renderer.image { _ in
			image.draw(in: CGRect(origin: .zero, size: targetSize))
		}
		return resizedImage
	}
	
	nonisolated func resize(cgImage: CGImage, to targetSize: CGSize) -> CGImage? {
		let width = Int(targetSize.width)
		let height = Int(targetSize.height)
		guard let context = CGContext(
			data: nil,
			width: width,
			height: height,
			bitsPerComponent: cgImage.bitsPerComponent,
			bytesPerRow: cgImage.bytesPerRow,
			space: cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
			bitmapInfo: cgImage.bitmapInfo.rawValue
		) else { fatalError() }
		
		context.interpolationQuality = .default
		context.draw(cgImage, in: CGRect(origin: .zero, size: targetSize))
		return context.makeImage()
	}
}
