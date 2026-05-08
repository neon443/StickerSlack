//
//  GifManager.swift
//  StickerSlack
//
//  Created by neon443 on 19/11/2025.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

class GifManager {
	//from clock-run, 12 frames one second
	static let defaultDuration: Double = 0.083333333333333329
	
	static func gifFrom(url: URL) async throws -> [(frame: UIImage, showFor: Double)] {
		let (data, _) = try await URLSession.shared.data(from: url)
		return gifFrom(data: data)
	}
	
	static func gifFrom(data: Data) -> [(frame: UIImage, showFor: Double)] {
		guard let source = CGImageSourceCreateWithData(data as NSData, nil) else { fatalError("couldnt create source") }
		let frameCount = CGImageSourceGetCount(source)
		var result: [(frame: UIImage, showFor: Double)] = []
		
		for i in 0..<frameCount {
			guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else {
				print("AAAA")
				continue
			}
			if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil),
			   let gifInfo = (properties as NSDictionary)[kCGImagePropertyGIFDictionary as String] as? NSDictionary,
			   let frameDuration = (gifInfo[kCGImagePropertyGIFDelayTime as String] as? NSNumber) {
				result.append((UIImage(cgImage: cgImage), frameDuration.doubleValue))
			} else {
				result.append((UIImage(cgImage: cgImage), defaultDuration))
			}
		}
		return result
	}
	
	nonisolated static func uiImageFrom(data: Data) -> UIImage? {
		guard let source = CGImageSourceCreateWithData(data as NSData, nil) else { fatalError("couldnt create source") }
		let frameCount = CGImageSourceGetCount(source)
		guard frameCount > 1 else { return UIImage(data: data) }
		
		var result: [UIImage] = []
		var frameDuration: Double = 0.0833333333
		
		for i in 0..<frameCount {
			guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else {
				print("AAAA")
				continue
			}
			if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil),
			   let gifInfo = (properties as NSDictionary)[kCGImagePropertyGIFDictionary as String] as? NSDictionary,
			   let duration = (gifInfo[kCGImagePropertyGIFDelayTime as String] as? NSNumber) {
				result.append(UIImage(cgImage: cgImage))
				frameDuration = Double(truncating: duration)
			} else {
				result.append(UIImage(cgImage: cgImage))
			}
		}
		
		return UIImage.animatedImage(with: result, duration: frameDuration*Double(frameCount))
	}
}
