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
	
	static func gifFrom(url: URL) async throws -> [(frame: CGImage, showFor: Double)] {
		let (data, _) = try await URLSession.shared.data(from: url)
		return gifFrom(data: data)
	}
	
	static func gifFrom(data: Data) -> [(frame: CGImage, showFor: Double)] {
		guard let source = CGImageSourceCreateWithData(data as NSData, nil) else { fatalError("couldnt create source") }
		let frameCount = CGImageSourceGetCount(source)
		var result: [(frame: CGImage, showFor: Double)] = []
		
		for i in 0..<frameCount {
			guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else {
				print("AAAA")
				continue
			}
			if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil),
			   let gifInfo = (properties as NSDictionary)[kCGImagePropertyGIFDictionary as String] as? NSDictionary,
			   let frameDuration = (gifInfo[kCGImagePropertyGIFDelayTime as String] as? NSNumber) {
				result.append((cgImage, frameDuration.doubleValue))
			} else {
				result.append((cgImage, defaultDuration))
			}
		}
		return result
	}
	
	static func dataFrom(frames: [(frame: CGImage, showFor: Double)]) -> Data? {
		var data = NSMutableData()
		
		let fileProperties = [
			kCGImagePropertyGIFDictionary: [
				kCGImagePropertyGIFLoopCount: 0
			]
		]
		
		guard let destination = CGImageDestinationCreateWithData(
			data,
			UTType.gif.identifier as CFString,
			frames.count,
			nil
		) else { fatalError() }
		
		CGImageDestinationSetProperties(destination, fileProperties as NSDictionary)
		
		for frame in frames {
			autoreleasepool {
				let frameProperties = [
					kCGImagePropertyGIFDictionary: [
						kCGImagePropertyGIFDelayTime: frame.showFor
					]
				]
				CGImageDestinationAddImage(
					destination,
					frame.frame,
					frameProperties as CFDictionary
				)
			}
		}
		
		guard CGImageDestinationFinalize(destination) else { fatalError() }
		return data as Data
	}
}
