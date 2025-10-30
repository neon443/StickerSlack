//
//  MSSticker.swift
//  StickerSlack
//
//  Created by neon443 on 30/10/2025.
//

import Foundation
import Messages

extension MSSticker {
	func validate() -> Bool {
		let sizeGood = try? Data(contentsOf: imageFileURL).count < 500_000
		let nameGood = self.description.count < 150
		return sizeGood ?? false && nameGood
	}
}
