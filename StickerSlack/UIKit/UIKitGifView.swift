//
//  UIKitGifView.swift
//  StickerSlack
//
//  Created by neon443 on 03/05/2026.
//

import Foundation
import UIKit

class UIKitGifView: UIImageView {
	override init(image: UIImage?) {
		super.init(image: image)
		self.contentMode = .scaleAspectFit
		if #available(iOS 17, *) {
			self.preferredImageDynamicRange = .high
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(with sticker: any StickerProtocol) async {
		let image = await prepareImage(for: sticker)
		await MainActor.run {
			UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve) {
				self.image = image
			}
		}
	}
	
	nonisolated func prepareImage(for sticker: any StickerProtocol) async -> UIImage? {
		let raw: Data?
		raw = await sticker.data()
		guard let raw else { return nil }
		return await render(data: raw)
	}
	
	nonisolated func render(data: Data) async -> UIImage {
		return await Task.detached(priority: .userInitiated) {
			return GifManager.uiImageFrom(data: data) ?? UIImage(systemName: "xmark")!
		}.value
	}
}
