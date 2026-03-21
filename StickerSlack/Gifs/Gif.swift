//
//  Gif.swift
//  StickerSlack
//
//  Created by neon443 on 06/03/2026.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct Gif: StickerProtocol {
	var id: String
	var name: String
	var localImageURLString: String {
		let urlString = remoteImageURL.absoluteString
		let split = urlString.split(separator: ".")
		let fileExtension = ".\(split.last ?? "png")"
		
		return GifHoarder.container.absoluteString+id+fileExtension
	}
	var remoteImageURL: URL
	
	//	enum CodingKeys: String, CodingKey {
	//
	//	}
	
	init(
		name: String,
		url: URL,
		id: String = UUID().uuidString
	) {
		self.id = id
		self.name = name
		self.remoteImageURL = url
	}
	
	func downloadImage() async throws {
		if let data = try? Data(contentsOf: localImageURL),
		   let _ = UIImage(data: data) {
			return
		}
		
		var (data, _) = try await URLSession.shared.data(from: remoteImageURL)
		
		if let uiImage = UIImage(data: data),
		   let cgImage = uiImage.cgImage,
		   !self.localImageURLString.contains(".gif"),
		   cgImage.width < 300 || cgImage.height < 300 {
			data = resize(image: uiImage, to: CGSize(width: 300, height: 300)).pngData()!
		}
		
		try! data.write(to: localImageURL)
		return
	}
	
	static var test: Gif = GifObject(
		type: "gif",
		id: "XAeEGyCbp8UehBPkSA",
		slug: "know-does-he-XAeEGyCbp8UehBPkSA",
		url: "https://giphy.com/gifs/know-does-he-XAeEGyCbp8UehBPkSA",
		bitly_url: "https://gph.is/g/4AKMQlV",
		embed_url: "https://giphy.com/embed/XAeEGyCbp8UehBPkSA",
		username: "Ommarbisafool",
		source: "",
		rating: "g",
		source_tld: "",
		source_post_url: "",
		import_datetime: "2025-11-06 15:48:02",
		images: GiphyImages(
			fixed_height: .init(
				url: "https://media2.giphy.com/media/XAeEGyCbp8UehBPkSA/200.gif?cid=acd65332fv0sn3gzwa5vi4jw834l2hhwmfm6d90329p1590n&ep=v1_gifs_search&rid=200.gif&ct=g",
				width: "270",
				height: "200",
				size: "74672",
				mp4: "https://media2.giphy.com/media/XAeEGyCbp8UehBPkSA/200.mp4?cid=acd65332fv0sn3gzwa5vi4jw834l2hhwmfm6d90329p1590n&ep=v1_gifs_search&rid=200.mp4&ct=g",
				mp4_size: "11433",
				webp: "https://media2.giphy.com/media/XAeEGyCbp8UehBPkSA/200.webp?cid=acd65332fv0sn3gzwa5vi4jw834l2hhwmfm6d90329p1590n&ep=v1_gifs_search&rid=200.webp&ct=g",
				webp_size: "10962"
			),
			fixed_height_still: nil,
			fixed_height_downsampled: .init(
				url: "https://media2.giphy.com/media/XAeEGyCbp8UehBPkSA/200_d.gif?cid=acd65332fv0sn3gzwa5vi4jw834l2hhwmfm6d90329p1590n&ep=v1_gifs_search&rid=200_d.gif&ct=g",
				width: "270",
				height: "200",
				size: "51332",
				webp: "https://media2.giphy.com/media/XAeEGyCbp8UehBPkSA/200_d.webp?cid=acd65332fv0sn3gzwa5vi4jw834l2hhwmfm6d90329p1590n&ep=v1_gifs_search&rid=200_d.webp&ct=g",
				webp_size: "44850"
			),
			fixed_height_small: .init(
				url: "https://media2.giphy.com/media/XAeEGyCbp8UehBPkSA/100.gif?cid=acd65332fv0sn3gzwa5vi4jw834l2hhwmfm6d90329p1590n&ep=v1_gifs_search&rid=100.gif&ct=g",
				width: "134",
				height: "100",
				size: "16461",
				mp4: "https://media2.giphy.com/media/XAeEGyCbp8UehBPkSA/100.mp4?cid=acd65332fv0sn3gzwa5vi4jw834l2hhwmfm6d90329p1590n&ep=v1_gifs_search&rid=100.mp4&ct=g",
				mp4_size: "5340",
				webp: "https://media2.giphy.com/media/XAeEGyCbp8UehBPkSA/100.webp?cid=acd65332fv0sn3gzwa5vi4jw834l2hhwmfm6d90329p1590n&ep=v1_gifs_search&rid=100.webp&ct=g",
				webp_size: "3142"
			),
			fixed_height_small_still: nil,
			fixed_width: .init(
				url: "https://media2.giphy.com/media/XAeEGyCbp8UehBPkSA/200w.gif?cid=acd65332fv0sn3gzwa5vi4jw834l2hhwmfm6d90329p1590n&ep=v1_gifs_search&rid=200w.gif&ct=g",
				width: "200",
				height: "148",
				size: "42579",
				mp4: "https://media2.giphy.com/media/XAeEGyCbp8UehBPkSA/200w.mp4?cid=acd65332fv0sn3gzwa5vi4jw834l2hhwmfm6d90329p1590n&ep=v1_gifs_search&rid=200w.mp4&ct=g",
				mp4_size: "8158",
				webp: "https://media2.giphy.com/media/XAeEGyCbp8UehBPkSA/200w.webp?cid=acd65332fv0sn3gzwa5vi4jw834l2hhwmfm6d90329p1590n&ep=v1_gifs_search&rid=200w.webp&ct=g",
				webp_size: "4458"
			),
			fixed_width_still: nil,
			fixed_width_downsampled: .init(
				url: "https://media2.giphy.com/media/XAeEGyCbp8UehBPkSA/200w_d.gif?cid=acd65332fv0sn3gzwa5vi4jw834l2hhwmfm6d90329p1590n&ep=v1_gifs_search&rid=200w_d.gif&ct=g",
				width: "200",
				height: "148",
				size: "23483",
				webp: "https://media2.giphy.com/media/XAeEGyCbp8UehBPkSA/200w_d.webp?cid=acd65332fv0sn3gzwa5vi4jw834l2hhwmfm6d90329p1590n&ep=v1_gifs_search&rid=200w_d.webp&ct=g",
				webp_size: "22586"
			),
			fixed_width_small: .init(
				url: "https://media2.giphy.com/media/XAeEGyCbp8UehBPkSA/100w.gif?cid=acd65332fv0sn3gzwa5vi4jw834l2hhwmfm6d90329p1590n&ep=v1_gifs_search&rid=100w.gif&ct=g",
				width: "100",
				height: "74",
				size: "8150",
				mp4: "https://media2.giphy.com/media/XAeEGyCbp8UehBPkSA/100w.mp4?cid=acd65332fv0sn3gzwa5vi4jw834l2hhwmfm6d90329p1590n&ep=v1_gifs_search&rid=100w.mp4&ct=g",
				mp4_size: "4103",
				webp: "https://media2.giphy.com/media/XAeEGyCbp8UehBPkSA/100w.webp?cid=acd65332fv0sn3gzwa5vi4jw834l2hhwmfm6d90329p1590n&ep=v1_gifs_search&rid=100w.webp&ct=g",
				webp_size: "1814"
			),
			fixed_width_small_still: nil,
			downsized: nil,
			downsized_still: nil,
			downsized_large: nil,
			downsized_medium: nil,
			downsized_small: nil,
			original: .init(
				url: "https://media2.giphy.com/media/XAeEGyCbp8UehBPkSA/giphy.gif?cid=acd65332fv0sn3gzwa5vi4jw834l2hhwmfm6d90329p1590n&ep=v1_gifs_search&rid=giphy.gif&ct=g",
				width: "480",
				height: "356",
				size: "245829",
				mp4: "https://media2.giphy.com/media/XAeEGyCbp8UehBPkSA/giphy.mp4?cid=acd65332fv0sn3gzwa5vi4jw834l2hhwmfm6d90329p1590n&ep=v1_gifs_search&rid=giphy.mp4&ct=g",
				mp4_size: "23259",
				webp: "https://media2.giphy.com/media/XAeEGyCbp8UehBPkSA/giphy.webp?cid=acd65332fv0sn3gzwa5vi4jw834l2hhwmfm6d90329p1590n&ep=v1_gifs_search&rid=giphy.webp&ct=g",
				webp_size: "26984"
			),
			original_still: nil,
//			looping: nil,
			preview: nil,
			preview_gif: nil
		),
		title: "Know GIF",
		alt_text: "",
		is_low_contrast: false
	).toGif
}
