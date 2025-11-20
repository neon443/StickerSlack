//
//  GifManager.swift
//  StickerSlack
//
//  Created by neon443 on 19/11/2025.
//

import Foundation
import UIKit

class GifManager {
	static let defaultDuration: Double = 0.083333333333333329
	static func gifFrom(url: URL) -> [(frame: CGImage, showFor: Double)] {
//		let url = URL(string: "https://emoji.slack-edge.com/T0266FRGM/yay-bounce/046cfcc7ed81030f.gif")!
//		guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { fatalError("couldnt create source") }
		
		guard let data = try? Data(contentsOf: url) else { return [] }
		
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
}
