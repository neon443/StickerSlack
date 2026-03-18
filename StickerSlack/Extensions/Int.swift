//
//  Int.swift
//  StickerSlack
//
//  Created by neon443 on 18/03/2026.
//

import Foundation

extension Int {
	var plural: String {
		return self == 1 ? "" : "s"
	}
}
