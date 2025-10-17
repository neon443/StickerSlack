//
//  Emoji.swift
//  StickerSlack
//
//  Created by neon443 on 17/10/2025.
//

import Foundation
import SwiftUI

struct Emoji: Codable, Hashable {
	var name: String
	var urlString: String
	var url: URL {
		return URL(string: urlString) ?? URL(string: "https://")!
	}
	var image: Image {
		if let data = try? Data(contentsOf: url),
		   let uiimage = UIImage(data: data) {
			return Image(uiImage: uiimage)
		}
		return Image(uiImage: UIImage())
	}
	
	init(name: String, url: String) {
		self.name = name
		self.urlString = url
	}
}
