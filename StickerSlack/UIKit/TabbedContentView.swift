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
		setupTabs()
	}
	
	private func setupTabs() {
		let emojiHoarder = EmojiHoarder()
		let gifHoarder = GifHoarder()
		
		let browseView = BrowseView(emojiHoarder: emojiHoarder, gifHoarder: gifHoarder)
		let browse = UIHostingController(rootView: browseView)
		browse.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
		
		let packsView = EmojiPackManager(hoarder: emojiHoarder)
		let packs = UIHostingController(rootView: packsView)
		packs.tabBarItem = UITabBarItem(title: "Packs", image: UIImage(systemName: "house"), tag: 1)
		
		let downloadedView = DownloadedView(emojiHoarder: emojiHoarder, gifHoarder: gifHoarder)
		let downloaded = UIHostingController(rootView: downloadedView)
		downloaded.tabBarItem = UITabBarItem(title: "Downloaded", image: UIImage(systemName: "house"), tag: 2)
		
		let settingsView = SettingsView(hoarder: emojiHoarder)
		let settings = UIHostingController(rootView: settingsView)
		settings.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 3)
		
		self.setViewControllers([browse], animated: true)
		selectedIndex = 0
		
	}
}

@available(iOS 17, *)
#Preview {
	let view2 = TabbedContentView()
	return view2.view
}
