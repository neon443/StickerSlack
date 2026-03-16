//
//  GifObject.swift
//  StickerSlack
//
//  Created by neon443 on 16/03/2026.
//

import Foundation

struct GifObject: Codable, Identifiable {
	var type: String
	var id: String
	var slug: String
	var url: String
	var bitly_url: String
	var embed_url: String
	var username: String
	var source: String
	var rating: String
	var content_url: String?
	var user: GiphyUser
	var source_tld: String
	var source_post_url: String
	var update_datetime: Date
	var create_datetime: Date
	var import_datetime: Date
	var trending_datetime: Date
	var images: GiphyImages
	var title: String
	var alt_text: String
	var is_low_contrast: Bool
}
