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
	var trailingVC: StickerBrowserViewController
	
	init(
		emojiHoarder: EmojiHoarder,
		leading: MessagesPackListView,
		trailing: StickerBrowserViewController
	) {
		self.emojiHoarder = emojiHoarder
		self.leadingVC = leading
		self.trailingVC = trailing
		super.init(nibName: nil, bundle: nil)
		leadingVC.onSelect = { pack in
			self.trailingVC.view.layoutIfNeeded()
			self.trailingVC.view.transform = .identity
			UIView.animate(withDuration: 0.25) {
				self.trailingVC.view.transform = CGAffineTransform.init(scaleX: 0.9, y: 0.9)
				self.trailingVC.view.alpha = 0
			} completion: { _ in
				self.trailingVC.pack = pack
				self.trailingVC.reload()
				UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1) {
					self.trailingVC.view.transform = .identity
					self.trailingVC.view.alpha = 1
				}
			}
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
