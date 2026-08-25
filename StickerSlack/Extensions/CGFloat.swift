//
//  CGFloat.swift
//  StickerSlack
//
//  Created by neon443 on 25/08/2026.
//

import Foundation

extension CGFloat {
	func rad() -> CGFloat {
		return (self / 180) * Self.pi
	}
	func deg() -> CGFloat {
		return (self / Self.pi) * 180
	}
}
