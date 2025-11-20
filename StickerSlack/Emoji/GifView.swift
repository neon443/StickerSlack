//
//  GifView.swift
//  StickerSlack
//
//  Created by neon443 on 20/11/2025.
//

import Foundation
import UIKit
import SwiftUI
import WebKit

struct GifView: UIViewRepresentable {
	private let url: URL
	
	init(url: URL) {
		self.url = url
	}
	
	func makeUIView(context: Context) -> WKWebView {
		let webview = WKWebView()
		
		webview.allowsLinkPreview = false
		webview.allowsBackForwardNavigationGestures = false
		
		webview.load(URLRequest(url: url))
		return webview
	}
	
	func updateUIView(_ uiView: WKWebView, context: Context) {
		uiView.reload()
	}
}
