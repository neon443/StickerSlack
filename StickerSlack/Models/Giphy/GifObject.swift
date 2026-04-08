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
	var user: GiphyUser?
	var source_tld: String
	var source_post_url: String
	var update_datetime: String?
	var create_datetime: String?
	var import_datetime: String
	var trending_datetime: String?
	var images: GiphyImages
	var title: String
	var alt_text: String
	var is_low_contrast: Bool
	
	var toGif: Gif {
		return Gif(
			name: self.slug,
			UIName: self.title,
			url: URL(string: self.images.original.url)!,
			giphyImages: images,
			id: self.id
		)
	}
}
