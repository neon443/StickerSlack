//
//  StickerSlackApp.swift
//  StickerSlack
//
//  Created by neon443 on 15/10/2025.
//

import SwiftUI

//@main
//struct StickerSlackApp: App {
//	@ObservedObject var emojiHoarder: EmojiHoarder = EmojiHoarder()
//	@ObservedObject var gifhoarder: GifHoarder = GifHoarder()
//	
//	@State var importingEmojiPack: Bool = false
//	@State var pack: EmojiPack = .new()
//	
//	var body: some Scene {
//		WindowGroup {
//			ContentView(emojiHoarder: emojiHoarder, gifhoarder: gifhoarder)
//				.onOpenURL { url in
//					if let imported = EmojiPack(fromShareLink: url) {
//						importingEmojiPack = true
//						pack = imported
//					}
//				}
//				.sheet(isPresented: $importingEmojiPack) {
//					EmojiPackImporterView(emojiHoarder: emojiHoarder, pack: $pack)
//				}
//		}
//	}
//}

@main
class StickerSlackApp: UIResponder, UIApplicationDelegate {
	#if DEBUG
	var emojiHoarder: EmojiHoarder = .init(/*localOnly: true*/)
	#else
	var emojiHoarder: EmojiHoarder = .init()
	#endif
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = TabbedContentView()
		(window?.rootViewController! as! TabbedContentView).setupTabs(with: emojiHoarder)
		window?.makeKeyAndVisible()
		return true
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
		guard app.canOpenURL(url) else { return false }
		guard let rootViewController = window?.rootViewController else { return false }

		guard let imported = EmojiPack(fromShareLink: url) else { return false }
		let importView = UIHostingController(rootView: EmojiPackImporterView(emojiHoarder: emojiHoarder, pack: .constant(imported)))
		
		if let sheet = importView.sheetPresentationController {
			sheet.detents = [.large()]
			sheet.prefersScrollingExpandsWhenScrolledToEdge = false
			sheet.prefersEdgeAttachedInCompactHeight = true
			sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
			sheet.prefersGrabberVisible = true
		}
		
		rootViewController.present(importView, animated: true)
		return true
	}
}
