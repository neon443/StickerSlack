//
//  StickerProtocol.swift
//  StickerSlack
//
//  Created by neon443 on 06/03/2026.
//

import Foundation
import Messages

protocol StickerProtocol: Codable, Identifiable, Hashable {
	var id: UUID { get set }
	var uiID: UUID { get set }
	var name: String { get set }
	
	var localImageURL: URL { get }
	var localImageURLString: String { get }
	var remoteImageURL: URL { get set }
	
	var isLocal: Bool { get }
	
	var msSticker: MSSticker? { get }
	var image: UIImage? { get }
	
	func downloadImage() async throws
	func deleteImage()
	mutating func refresh()
	func resize(image: UIImage, to targetSize: CGSize) -> UIImage
	static var test: Self { get }
}
