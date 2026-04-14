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
	
	init(_ enabled: Bool = true) {
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

struct NavigationView2<T: View>: View {
	@ViewBuilder var contents: T
	
	var body: some View {
		if #available(iOS 16, *) {
			NavigationStack {
				contents
			}
		} else {
			NavigationView {
				contents
			}
		}
	}
}

struct presentationHalfAndFullIfAv: ViewModifier {
	func body(content: Content) -> some View {
		if #available(iOS 16, *) {
			content
				.presentationDetents([.medium, .large])
				.presentationDragIndicator(.visible)
		} else {
			content
		}
	}
}

struct BoldSafe: ViewModifier {
	var isEnabled: Bool = true
	var style: Font.TextStyle = .body
	
	func body(content: Content) -> some View {
		if #available(iOS 16, *) {
			content.bold(isEnabled)
		} else {
			if isEnabled {
				content.font(.system(style).bold())
			} else {
				content.font(.system(style))
			}
		}
	}
}

struct MonospacedSafe: ViewModifier {
	var isEnabled: Bool = true
	var style: Font.TextStyle = .body
	
	func body(content: Content) -> some View {
		if #available(iOS 16, *) {
			content.monospaced(isEnabled)
		} else {
			if isEnabled {
				content.font(.system(style).monospaced())
			} else {
				content.font(.system(style))
			}
		}
	}
}

struct ScrollContentBackgroundHidden: ViewModifier {
	func body(content: Content) -> some View {
		if #available(iOS 16, *) {
			content.scrollContentBackground(.hidden)
		} else {
			content
		}
	}
}

struct TabViewBottomAcceessorySafe<T: View>: ViewModifier {
	var isEnabled: Bool
	@ViewBuilder var contents: () -> T
	
	func body(content: Content) -> some View where Content: View {
		if #available(iOS 26.1, *) {
			content
				.tabViewBottomAccessory(isEnabled: isEnabled, content: contents)
		} else {
			content
		}
	}
}

extension View {
	func tabViewBottomAccessorySafe<Content: View>(
		isEnabled: Bool = true,
		@ViewBuilder content: @escaping () -> Content
	) -> some View {
		modifier(TabViewBottomAcceessorySafe(isEnabled: isEnabled, contents: content))
	}
}
