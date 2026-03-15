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
	
	
	func download(emoji: Emoji, skipStoreIndex: Bool) {
//		<#code#>
	}
	
	func delete(emoji: Emoji, skipStoreIndex: Bool) {
//		<#code#>
	}
	
	init() {
		var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)
		components?.queryItems = [
			URLQueryItem(name: "api_key", value: GifHoarder.apiKey),
			URLQueryItem(name: "limit", value: "100")
		]
		Task {
			do {
				async let (data, _) = try URLSession.shared.data(from: components!.url!)
				dump(try await data)
				print(try await data.base64EncodedString())
			} catch {
				print(error.localizedDescription)
			}
		}
	}
}
