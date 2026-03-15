//
//  GifHoarder.swift
//  StickerSlack
//
//  Created by neon443 on 06/03/2026.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import Combine

class GifHoarder: Hoarder, ObservableObject {
	static let container: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.neon443.StickerSlack")!.appendingPathComponent("Library", conformingTo: .directory)
	
	var endpoint: URL = URL(string: "https://api.giphy.com/v1/gifs/trending")!
	var endpointSearch: URL = URL(string: "https://api.giphy.com/v1/gifs/search")!
	
	@Published var searchTerm: String = ""
	@Published var trendingGifs: [Gif] = []
	
	
	func download(emoji: Emoji, skipStoreIndex: Bool) {
//		<#code#>
	}
	
	func delete(emoji: Emoji, skipStoreIndex: Bool) {
//		<#code#>
	}
	
	init() {
		var request = URLRequest(url: endpoint)
		request.setValue("", forHTTPHeaderField: "api_key")
		request.setValue("100", forHTTPHeaderField: "limit")
		Task {
			do {
				async let (data, _) = try URLSession.shared.data(from: endpoint)
				dump(await data)
				print(await data.base64EncodedString())
			}
		}
	}
}
