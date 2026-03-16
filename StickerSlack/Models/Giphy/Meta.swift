//
//  Meta.swift
//  StickerSlack
//
//  Created by neon443 on 16/03/2026.
//

import Foundation

struct Meta: Codable, Identifiable {
	var msg: String
	var status: Int
	var response_id: String
	var id: String { response_id }
	
	static var example: Meta {
		Meta(msg: "OK", status: 200, response_id: "57eea03c72381f86e05c35d2")
	}
}
