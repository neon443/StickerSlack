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

class GifHoarder: BaseHoarder {
	static let container: URL = library.appendingPathComponent("giphy", conformingTo: .directory)
	
	static var apiKey: String = "a2mFsDTpX5blodY8ltkG6Q1xy5NgFSbc"
	var endpoint: URL = URL(string: "https://api.giphy.com/v1/gifs/trending")!
	var endpointSearch: URL = URL(string: "https://api.giphy.com/v1/gifs/search")!
	
	@Published var searchTerm: String = ""
	@Published var trendingGifs: [Gif] = []
	//	@Published override var downloadedStickers: Set<String> = []
	
	
	override func download(emoji: any StickerProtocol, skipStoreIndex: Bool = false) async {
		await super.download(emoji: emoji, skipStoreIndex: skipStoreIndex)
	}
	
	override func delete(emoji: any StickerProtocol, skipStoreIndex: Bool = false) {
		super.delete(emoji: emoji, skipStoreIndex: skipStoreIndex)
	}
	
	init(localOnly: Bool = false) {
		super.init()
		if !FileManager.default.fileExists(atPath: GifHoarder.container.path()) {
			try! FileManager.default.createDirectory(at: GifHoarder.container, withIntermediateDirectories: true)
		}
		startLoadingTrending()
	}
	
	func startLoadingTrending() {
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
