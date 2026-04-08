//
//  Sticker.swift
//  StickerSlack
//
//  Created by neon443 on 06/03/2026.
//

import Foundation
import Messages

nonisolated
extension StickerProtocol {
	nonisolated var localImageURLString: String {
		let urlString = remoteImageURL.absoluteString
		let split = urlString.split(separator: ".")
		let fileExtension = ".\(split.last ?? "png")"
		
		return GifHoarder.container.path()+name+"."+id+fileExtension
	}
	
	nonisolated var localImageURL: URL {
		return URL(filePath: localImageURLString)
	}
	
	nonisolated
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
	
	nonisolated
	func deleteImage() {
		try? FileManager.default.removeItem(at: localImageURL)
		return
	}
}

@MainActor
extension StickerProtocol {
	func resize(image: UIImage, to targetSize: CGSize) -> UIImage {
		let oldSize = image.size
		let ratio: (x: CGFloat, y: CGFloat)
		ratio.x = targetSize.width / oldSize.width
		ratio.y = targetSize.height / oldSize.height
		
		var newSize: CGSize
		if ratio.x > ratio.y {
			newSize = CGSize(width: oldSize.width * ratio.y, height: oldSize.height * ratio.y)
		} else {
			newSize = CGSize(width: oldSize.width * ratio.x, height: oldSize.height * ratio.x)
		}
		
		let rect = CGRect(origin: .zero, size: newSize)
		
		if let frames = image.images {
			var result: [UIImage] = []
			for frame in frames {
				UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
				frame.draw(in: rect)
				result.append(UIGraphicsGetImageFromCurrentImageContext() ?? UIImage())
				UIGraphicsEndImageContext()
			}
			return UIImage.animatedImage(with: result, duration: image.duration) ?? UIImage()
		}
		
		UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
		image.draw(in: rect)
		return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
	}
	
	/*nonisolated*/ var msSticker: MSSticker? {
		guard FileManager.default.fileExists(atPath: localImageURLString) else {
			return nil
		}
		return try? MSSticker(contentsOfFileURL: localImageURL, localizedDescription: name)
	}
	
	/*nonisolated*/ var image: UIImage? {
		if FileManager.default.fileExists(atPath: localImageURLString),
		   let data = try? Data(contentsOf: localImageURL),
		   let img = UIImage(data: data) {
			return img
		} else {
			return nil
		}
	}
}
