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
	@State var error: Error?
	@State var failed: Bool = false
	
	func run() async {
		do {
			if gif.isEmpty {
				let frames = try await GifManager.gifFrom(url: url)
				withAnimation(.spring) {
					self.gif = frames
				}
			}
		} catch {
			self.error = error
		}
		guard self.error == nil && !self.gif.isEmpty else {
			print("falied loading or empty gif")
			withAnimation(.spring) { self.failed = true }
			return
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
	
	var body: some View {
//		/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
		TimelineView(.animation) { tl in
			VStack {
				if gif.isEmpty && error == nil {
					ProgressView()
						.controlSize(.large)
						.frame(maxWidth: .infinity, maxHeight: .infinity)
				} else if failed {
					Image(systemName: "xmark")
						.resizable().scaledToFit()
						.padding()
						.padding()
						.background(.red)
				} else {
					if currentI < gif.count {
						let image = Image(uiImage: .init(cgImage: gif[currentI].frame))
						image
							.resizable().scaledToFit()
					}
				}
			}
			.transition(.scale)
		}
		.onDisappear {
			timer?.invalidate()
			timer = nil
		}
		.task {
			await run()
		}
	}
}

#Preview {
	GifView(
		url: URL(string: "https://emoji.slack-edge.com/T09V59WQY1E/clockrun/f6641714fa6748ac.gif")!
	)
	GifView(url: Emoji.test.remoteImageURL)
	GifView(url: Emoji.testLongName.localImageURL)
	GifView(url: Gif.test.remoteImageURL)
}
