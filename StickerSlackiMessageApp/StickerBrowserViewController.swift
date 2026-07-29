//
//  StickerBrowserViewController.swift
//  StickerSlackiMessageApp
//
//  Created by neon443 on 30/07/2026.
//

import Foundation
import UIKit
import Messages
import SwiftUI

class StickerBrowserViewController: MSStickerBrowserViewController {
	var emojiHoarder: EmojiHoarder!
	var dataSource: StickerBrowserDataSource!
	
	init(emojiHoarder: EmojiHoarder, pack: EmojiPack?) {
		self.emojiHoarder = emojiHoarder
		self.dataSource = StickerBrowserDataSource(hoarder: emojiHoarder, pack: pack)
		super.init(stickerSize: .small)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.emojiHoarder = EmojiHoarder(localOnly: true, skipIndex: true)
		self.dataSource = StickerBrowserDataSource(hoarder: emojiHoarder, pack: nil)
	
		let stickerBrowser = MSStickerBrowserView(frame: .zero, stickerSize: .small)
		stickerBrowser.dataSource = dataSource
		
		guard stickerBrowser.dataSource?.numberOfStickers(in: stickerBrowser) != 0 else {
			let swiftUIView = NoStickersView()
			let hostingController = UIHostingController(rootView: swiftUIView)
			hostingController.view.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(hostingController.view)
			
			NSLayoutConstraint.activate([
				hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
				hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
			])
			return
		}
		
		stickerBrowser.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(stickerBrowser)
		stickerBrowser.contentInset = .zero
		NSLayoutConstraint.activate([
			stickerBrowser.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			stickerBrowser.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			stickerBrowser.topAnchor.constraint(equalTo: view.topAnchor),
			stickerBrowser.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
		return
		
		// Called when the extension is about to move from the inactive to active state.
		// This will happen when the extension is about to present UI.
		
		// Use this method to configure the extension and restore previously stored state.
	}
}
