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
	
	nonisolated func run() async {
		guard await url.pathExtension == "gif" else {
			if let data = try? await URLSession.shared.data(from: url).0,
			   let uiImage = UIImage(data: data),
			   let cgImage = uiImage.cgImage {
				withAnimation(.spring) {
					self.gif = [(cgImage, 1)]
				}
			}
			return
		}
		
		do {
			if await gif.isEmpty {
				let frames = try await GifManager.gifFrom(url: url)
				withAnimation(.spring) {
					self.gif = frames
				}
			}
		} catch {
			print(error)
			print(error.localizedDescription)
			print("falied loading or empty gif")
			return
		}
		if await timer != nil {
			await timer!.invalidate()
			timer = nil
		}
		
		timer = Timer(timeInterval: gif[0].showFor, repeats: true) { timer in
			if currentI == (gif.count-1) {
				currentI = 0
			} else {
				currentI += 1
			}
		}
		await RunLoop.main.add(timer!, forMode: .common)
	}
	
	var body: some View {
//		/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
		Group {
			if gif.isEmpty {
				ProgressView()
//					.controlSize(.large)
			} else if url.pathExtension == "gif" {
				TimelineView(.animation) { tl in
					if currentI < gif.count {
						Image(uiImage: .init(cgImage: gif[currentI].frame))
							.resizable().scaledToFit()
					}
				}
				.onDisappear {
					timer?.invalidate()
					timer = nil
				}
			} else {
				if let frame = gif.first {
					Image(uiImage: .init(cgImage: frame.frame))
						.resizable().scaledToFit()
				}
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.transition(.scale)
		.onAppear {
			Task {
				await run()
			}
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
