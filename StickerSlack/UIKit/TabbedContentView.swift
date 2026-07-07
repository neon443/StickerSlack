//
//  TabbedContentView.swift
//  StickerSlack
//
//  Created by neon443 on 26/06/2026.
//

import Foundation
import UIKit
import SwiftUI

final class TabbedContentView: UITabBarController, UITabBarControllerDelegate {
	func setupTabs(with emojiHoarder: EmojiHoarder) {
		self.delegate = self
		
		let browse = BrowseViewController(emojiHoarder: emojiHoarder)
		browse.tabBarItem = UITabBarItem(title: "Browse", image: UIImage(systemName: "square.grid.2x2.fill"), tag: 0)
		
//		let packsView = EmojiPackManager(hoarder: emojiHoarder)
//		let packs = UIHostingController(rootView: packsView)
		let packs = EmojiPackManagerController(emojiHoarder: emojiHoarder)
//		let packs = EmojiPackDetailViewController(with: emojiHoarder, andPack: .test)
		packs.tabBarItem = UITabBarItem(title: "Packs", image: UIImage(systemName: "square.stack.3d.up.fill"), tag: 1)
		
		let downloaded = DownloadedViewController(emojiHoarder: emojiHoarder)
		downloaded.tabBarItem = UITabBarItem(title: "Saved", image: UIImage(systemName: "arrow.down.circle.fill"), tag: 2)
		
//		let searchView = SearchView(hoarder: emojiHoarder)
//		let search = UIHostingController(rootView: searchView)
		let search = SearchViewController(emojiHoarder: emojiHoarder)
		search.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 3)
		
		
		let settingsView = SettingsView(hoarder: emojiHoarder)
		let settings = UIHostingController(rootView: settingsView)
		settings.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 4)
		
		self.setViewControllers([browse, packs, downloaded, search, settings], animated: false)
	}
	
	func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		guard let selectedVc = selectedViewController else { return true }
		if viewController.tabBarItem.tag == selectedVc.tabBarItem.tag {
			guard let navController = viewController as? UINavigationController else { return true }
			navController.popToRootViewController(animated: true)
			return true
		}
		return true
	}
	
//	override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//		item
//	}/
	
	
//	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//		let navController = viewController as! UINavigationController
//		navController.popViewController(animated: true)
//	}

}
