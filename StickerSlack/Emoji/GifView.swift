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
	
	@State var timer: Timer?
	
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
		.onDisappear {
			timer?.invalidate()
			timer = nil
		}
		.task {
			if gif.isEmpty {
				self.gif = await GifManager.gifFrom(url: url)
			}
			guard gif.count > 0 else { return }
			
			if timer != nil {
				timer!.invalidate()
				timer = nil
			}
			
			timer = Timer(timeInterval: gif[0].showFor, repeats: true) { timer in
				if currentI == (gif.count-1) {
					currentI = 0
				} else {
					currentI += 1
				}
			}
			RunLoop.main.add(timer!, forMode: .common)
		}
	}
}

#Preview {
	GifView(
		url: URL(string: "https://emoji.slack-edge.com/T0266FRGM/clockrun/ec33c513d30a6ed8.gif")!
	)
}
