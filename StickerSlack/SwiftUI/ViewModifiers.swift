//
//  ViewModifiers.swift
//  StickerSlack
//
//  Created by neon443 on 03/11/2025.
//

import Foundation
import SwiftUI

struct numericTextCompat: ViewModifier {
	func body(content: Content) -> some View {
		if #available(iOS 16, *) {
			content.contentTransition(.numericText())
		} else {
			content.transition(.opacity)
		}
	}
}

struct tabViewActivationSearchActivation: ViewModifier {
	func body(content: Content) -> some View {
		if #available(iOS 26, *) {
			content.tabViewSearchActivation(.searchTabSelection)
		} else {
			content
		}
	}
}

struct glassButtonIfAv: ViewModifier {
	var enabled: Bool
	
	init(_ enabled: Bool) {
		self.enabled = enabled
	}
	
	func body(content: Content) -> some View {
		if enabled {
			if #available(iOS 19, *) {
				content.buttonStyle(.glassProminent)
			} else {
				content.buttonStyle(.borderedProminent)
			}
		} else {
			content
		}
	}
}
