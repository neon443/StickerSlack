//
//  GiphyImages.swift
//  StickerSlack
//
//  Created by neon443 on 16/03/2026.
//

import Foundation

struct GiphyImages: Codable, Equatable, Hashable {
	//fixed height of 200px
	var fixed_height: motion
	//fixed height of 200px still
	var fixed_height_still: still?
	//fixed height 200px with 6 frames
	var fixed_height_downsampled: downsampled
	
	//fixed height of 100px
	var fixed_height_small: motion
	//fixed height of 100px still
	var fixed_height_small_still: still?
	
	//fixed width of 200px
	var fixed_width: motion
	//fixed width of 200px
	var fixed_width_still: still?
	//fixed width 200px with 6 frames
	var fixed_width_downsampled: downsampled
	
	//fixed width of 100px
	var fixed_width_small: motion
	//fixed width of 100px still
	var fixed_width_small_still: still?
	
	//under 2mb
	var downsized: downsized?
	//downsized still
	var downsized_still: still?
	//under 8mb
	var downsized_large: downsized?
	//under 5mb
	var downsized_medium: downsized?
	//under 200kb
	var downsized_small: video?
	
	var original: motion
	var original_still: still?
	
	//15s looping version
//	var looping: looping?
	//mp4 format 50kb, first 1-2s of the gif
	var preview: video?
	//50kb first 1-2s of the gif
	var preview_gif: still?
	
	
	struct motion: Codable, Equatable, Hashable {
		var url: String
		var width: String
		var height: String
		var size: String
		var mp4: String
		var mp4_size: String
		var webp: String
		var webp_size: String
	}
	struct still: Codable, Equatable, Hashable {
		var url: String
		var width: String
		var height: String
	}
	struct downsampled: Codable, Equatable, Hashable {
		var url: String
		var width: String
		var height: String
		var size: String
		var webp: String
		var webp_size: String
	}
	struct downsized: Codable, Equatable, Hashable {
		var url: String
		var width: String
		var height: String
		var size: String
	}
	struct looping: Codable, Equatable, Hashable {
		var mp4: String
	}
	struct video: Codable, Equatable, Hashable {
		var mp4: String
		var mp4_size: String
		var width: String
		var height: String
	}
}
