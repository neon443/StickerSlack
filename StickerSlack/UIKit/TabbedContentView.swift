//
//  TabbedContentView.swift
//  StickerSlack
//
//  Created by neon443 on 26/06/2026.
//

import Foundation
import UIKit
import SwiftUI

final class TabbedContentView: UITabBarController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.edgesForExtendedLayout = .bottom
		self.extendedLayoutIncludesOpaqueBars = false
		
		if #available(iOS 26, *) {
			let appearance = UITabBarAppearance()
			appearance.configureWithDefaultBackground()
			tabBar.standardAppearance = appearance
			tabBar.scrollEdgeAppearance = appearance
		} else {
			self.tabBarController?.tabBar.isTranslucent = false
		}
		setupTabs()
	}
	
	private func setupTabs() {
		let emojiHoarder = EmojiHoarder()
		let gifHoarder = GifHoarder()
		
		let browseView = EmojiTableView(hoarder: emojiHoarder, items: emojiHoarder.emojis.map { $0.name })
		let browse = UINavigationController(rootViewController: browseView)
		browseView.navigationItem.title = "Browse"
		browse.tabBarItem = UITabBarItem(title: "Browse", image: UIImage(systemName: "square.grid.2x2.fill"), tag: 0)
		
		let packsView = EmojiPackManager(hoarder: emojiHoarder)
		let packs = UIHostingController(rootView: packsView)
		packs.tabBarItem = UITabBarItem(title: "Packs", image: UIImage(systemName: "square.stack.3d.up.fill"), tag: 1)
		
		let downloadedView = DownloadedView(emojiHoarder: emojiHoarder, gifHoarder: gifHoarder)
		let downloaded = UIHostingController(rootView: downloadedView)
		downloaded.tabBarItem = UITabBarItem(title: "Downloaded", image: UIImage(systemName: "arrow.down.circle.fill"), tag: 2)
		
		let settingsView = SettingsView(hoarder: emojiHoarder)
		let settings = UIHostingController(rootView: settingsView)
		settings.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 3)
		
		let searchView = SearchView(hoarder: emojiHoarder)
		let search = UIHostingController(rootView: searchView)
		search.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 4)
		
		self.setViewControllers([browse, packs, downloaded, settings, search], animated: false)
	}
}
