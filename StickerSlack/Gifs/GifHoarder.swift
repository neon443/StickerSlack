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
	
	static var apiKey: String = "a2mFsDTpX5blodY8ltkG6Q1xy5NgFSbc"
	var endpoint: URL = URL(string: "https://api.giphy.com/v1/gifs/trending")!
	var endpointSearch: URL = URL(string: "https://api.giphy.com/v1/gifs/search")!
	
	@Published var searchTerm: String = ""
	@Published var trendingGifs: [Gif] = []
	@Published var downloadedStickers: Set<String> = []
	
	
	func download(emoji: any StickerProtocol, skipStoreIndex: Bool = false) {
//		<#code#>
	}
	
	func delete(emoji: any StickerProtocol, skipStoreIndex: Bool = false) {
//		<#code#>
	}
	
	init(localOnly: Bool = false) {
		var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)
		components?.queryItems = [
			URLQueryItem(name: "api_key", value: GifHoarder.apiKey),
			URLQueryItem(name: "limit", value: "500")
		]
		guard let finalURL = components?.url else { fatalError("invalid URL for request for trending gifs") }
		
		Task {
			do {
				let (data, _) = try await URLSession.shared.data(from: finalURL)
				let object: Trending = try JSONDecoder().decode(Trending.self, from: data)
				guard object.meta.status == 200 else {
					fatalError("non ok status code")
				}
				trendingGifs = object.data.map { $0.toGif }
			} catch {
				print(error)
			}
		}
	}
}
