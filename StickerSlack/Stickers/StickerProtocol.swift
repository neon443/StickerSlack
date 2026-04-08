//
//  StickerProtocol.swift
//  StickerSlack
//
//  Created by neon443 on 06/03/2026.
//

import Foundation
import Messages

nonisolated
protocol StickerProtocol: Codable, Identifiable, Hashable {
	nonisolated var id: String { get set }
	nonisolated var name: String { get set }
	
	nonisolated var typeGlyph: String { get }
	
	nonisolated var localImageURL: URL { get }
	nonisolated var localImageURLString: String { get }
	nonisolated var remoteImageURL: URL { get set }
	
	nonisolated var msSticker: MSSticker? { get }
	nonisolated var image: UIImage? { get }
	
	nonisolated func downloadImage() async throws
	nonisolated func deleteImage()
	nonisolated func resize(image: UIImage, to targetSize: CGSize) -> UIImage
	nonisolated static var test: Self { get }
}
