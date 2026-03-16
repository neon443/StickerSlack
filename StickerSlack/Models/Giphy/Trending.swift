//
//  Trending.swift
//  StickerSlack
//
//  Created by neon443 on 16/03/2026.
//

import Foundation

struct Trending: Codable {
	var data: [GifObject]
	var pagination: Pagination
	var meta: Meta
}
