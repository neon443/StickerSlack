//
//  SceneDelegate.swift
//  StickerSlack
//
//  Created by neon443 on 14/10/2026.
//

import Foundation
import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = scene as? UIWindowScene else { return }
		window = UIWindow(windowScene: windowScene)
		
		window?.rootViewController = TabbedContentView()
		(window?.rootViewController! as! TabbedContentView).setupTabs(with: StickerSlackApp.emojiHoarder)
		window?.makeKeyAndVisible()
		
		if StickerSlackApp.emojiHoarder.showWelcome {
			let welcomeView = UIHostingController(rootView: WelcomeView(emojiHoarder: StickerSlackApp.emojiHoarder))
			if welcomeView.sheetPresentationController != nil {
				self.window?.rootViewController?.present(welcomeView, animated: true)
			}
		}
		
	}
	
	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		guard let context = URLContexts.first else { return }
		
		guard UIApplication.shared.canOpenURL(context.url) else { return }
		guard let rootViewController = window?.rootViewController else { return }

		guard var imported = EmojiPack(fromShareLink: context.url) else { return }
		let importView = EmojiPackImporterViewController(emojiHoarder: StickerSlackApp.emojiHoarder, pack: imported)
		
		if let sheet = importView.sheetPresentationController {
			sheet.detents = [.large()]
			sheet.prefersScrollingExpandsWhenScrolledToEdge = false
			sheet.prefersEdgeAttachedInCompactHeight = true
			sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
			sheet.prefersGrabberVisible = true
		}
		
		rootViewController.present(importView, animated: true)
	}
	
	func sceneDidDisconnect(_ scene: UIScene) {
//		<#code#>
	}
	
	func sceneDidBecomeActive(_ scene: UIScene) {
//		<#code#>
	}
	
	func sceneWillResignActive(_ scene: UIScene) {
//		<#code#>
	}
	
	func sceneWillEnterForeground(_ scene: UIScene) {
//		<#code#>
	}
	
	func sceneDidEnterBackground(_ scene: UIScene) {
//		<#code#>
	}
}
