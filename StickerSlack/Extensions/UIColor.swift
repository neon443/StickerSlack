//
//  UIColor.swift
//  StickerSlack
//
//  Created by neon443 on 02/08/2026.
//

import Foundation
import UIKit

extension UIColor {
	var inverted: UIColor {
		var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
		if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
			return UIColor(red: 1.0-r, green: 1.0-g, blue: 1.0-b, alpha: a)
		} else {
			return .clear
		}
	}
}
