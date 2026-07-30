//
//  MessagesRootViewController.swift
//  StickerSlackiMessageApp
//
//  Created by neon443 on 29/07/2026.
//

import Foundation
import UIKit
import Messages

class MessagesRootViewController: UIViewController {
	var emojiHoarder: EmojiHoarder
	var leadingVC: MessagesPackListView
	var trailingVC: UIViewController
	
	init(
		emojiHoarder: EmojiHoarder,
		leading: UIViewController,
		trailing: UIViewController
	) {
		self.emojiHoarder = emojiHoarder
		self.leadingVC = MessagesPackListView(hoarder: emojiHoarder)
		self.trailingVC = trailing
		super.init(nibName: nil, bundle: nil)
		leadingVC.onSelect = { pack in
			self.trailingVC.view.removeFromSuperview()
			self.trailingVC.removeFromParent()
			self.trailingVC.didMove(toParent: nil)
			self.trailingVC = StickerBrowserViewController(emojiHoarder: emojiHoarder, pack: pack)
			self.addChild(self.trailingVC)
			self.view.addSubview(self.trailingVC.view)
			self.trailingVC.view.translatesAutoresizingMaskIntoConstraints = false
			NSLayoutConstraint.activate([
				self.trailingVC.view.topAnchor.constraint(equalTo: self.view.topAnchor),
				self.trailingVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
				self.trailingVC.view.leadingAnchor.constraint(equalTo: self.leadingVC.view.trailingAnchor),
				self.trailingVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
			])
			self.trailingVC.didMove(toParent: self)
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		addChild(leadingVC)
		addChild(trailingVC)
		
		view.addSubview(leadingVC.view)
		view.addSubview(trailingVC.view)
		
		leadingVC.view.translatesAutoresizingMaskIntoConstraints = false
		trailingVC.view.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			leadingVC.view.topAnchor.constraint(equalTo: view.topAnchor),
			leadingVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			leadingVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			leadingVC.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25),
			
			trailingVC.view.topAnchor.constraint(equalTo: view.topAnchor),
			trailingVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			trailingVC.view.leadingAnchor.constraint(equalTo: leadingVC.view.trailingAnchor),
			trailingVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])
		
		leadingVC.didMove(toParent: self)
		trailingVC.didMove(toParent: self)
	}
}
