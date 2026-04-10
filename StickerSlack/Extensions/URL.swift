//
//  URL.swift
//  StickerSlack
//
//  Created by neon443 on 10/04/2026.
//

import Foundation

extension URL {
	nonisolated var safePath: String {
		if #available(iOS 16, *) {
			return self.path()
		} else {
			return self.path
		}
	}
	
	nonisolated var safeHost: String? {
		if #available(iOS 16, *) {
			return self.host()
		} else {
			return self.host
		}
	}
}
