//
//  StickerSlackApp.swift
//  StickerSlack
//
//  Created by neon443 on 15/10/2025.
//

import UIKit
import SwiftUI

@main
class StickerSlackApp: UIResponder, UIApplicationDelegate {
	static var emojiHoarder: EmojiHoarder = .init()
	
	var window: UIWindow?
	
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
	) -> Bool {
		return true
	}
		
	func application(
			_ application: UIApplication,
			configurationForConnecting connectingSceneSession: UISceneSession,
			options: UIScene.ConnectionOptions
	) -> UISceneConfiguration {
		let config = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
		config.delegateClass = SceneDelegate.self
		
		return config
	}
}
