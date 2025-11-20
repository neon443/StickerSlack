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

struct GifView: View {
	@State var url: URL
	@State var gif: [(frame: CGImage, showFor: Double)] = []
	@State var currentI: Int = 0
	@State var go: Bool = false
	
	var body: some View {
//		/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
		TimelineView(.animation) { tl in
			VStack {
				if currentI < gif.count {
					let image = Image(uiImage: .init(cgImage: gif[currentI].frame))
					image
						.resizable().scaledToFit()
				}
			}
		}
		.onChange(of: go) { _ in
			if currentI == (gif.count-1) {
				currentI = 0
			} else {
				currentI += 1
			}
			DispatchQueue.main.asyncAfter(deadline: .now()+gif[currentI].showFor) {
				go.toggle()
			}
		}
		.onAppear {
			self.gif = GifManager.gifFrom(url: url)
			DispatchQueue.main.asyncAfter(deadline: .now()+gif[0].showFor) {
				go.toggle()
			}
		}
	}
}

#Preview {
	GifView(
		url: URL(string: "https://files.catbox.moe/3x5sea.gif")!
	)
}
