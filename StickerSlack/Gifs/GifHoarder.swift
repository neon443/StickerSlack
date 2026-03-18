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
	
	static var apiKey: String = ""
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
			URLQueryItem(name: "limit", value: "100")
		]
		Task {
			do {
				async let (data, _) = try URLSession.shared.data(from: components!.url!)
				let object: Trending = try JSONDecoder().decode(Trending.self, from: await data)
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
