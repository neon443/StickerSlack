//
//  Pagination.swift
//  StickerSlack
//
//  Created by neon443 on 16/03/2026.
//

import Foundation

struct Pagination: Codable {
	var offset: Int
	var total_count: Int?
	var count: Int
	
	static var example: Pagination {
		Pagination(offset: 2591, total_count: 250, count: 25)
	}
}
