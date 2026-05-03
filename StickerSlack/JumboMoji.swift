//
//  JumboMoji.swift
//  StickerSlack
//
//  Created by neon443 on 03/05/2026.
//

import Foundation

struct JumboMoji {
	var width: Int
	var height: Int
	var baseName: String
	var type: JumboMoji.Style
	var items: [String]
	
//	init(baseName: String, items: [String]) {
//		let itemsBaseNameRemoved = items.map { String($0.dropFirst(baseName.count+1)) }
//		
//		
//		let coordinates = itemsBaseNameRemoved.map { $0.dropLast($0.split(separator: "-").last?.count ?? 0) }.split(separator: "-").map { Int(String($0)) }
//		self.width = width
//		self.height = height
//		self.baseName = baseName
//		self.type = type
//		self.items = items
//	}
	
	enum Style {
		case grid
		case btn
	}
}
