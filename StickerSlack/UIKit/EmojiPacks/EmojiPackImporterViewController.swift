//
//  EmojiPackImporterViewController.swift
//  StickerSlack
//
//  Created by neon443 on 02/08/2026.
//

import Foundation
import UIKit

class EmojiPackImporterViewController: UINavigationController {
	var emojiHoarder: EmojiHoarder
	var packView: EmojiPackDetailViewController
	var addButton: UIButton
	var cancelButton: UIButton
	
	init(emojiHoarder: EmojiHoarder, pack: EmojiPack) {
		self.emojiHoarder = emojiHoarder
		self.packView = EmojiPackDetailViewController(with: emojiHoarder, andPack: pack)
		
		var config: UIButton.Configuration
		if #available(iOS 19, *) {
			config = .prominentClearGlass()
		} else {
			config = .filled()
		}
		config.title = "Add"
		config.cornerStyle = .capsule
		config.baseBackgroundColor = .accent
		config.buttonSize = .large
		self.addButton = UIButton(configuration: config)
		
		if #available(iOS 19, *) {
			config = .glass()
		} else {
			config = .filled()
			config.baseBackgroundColor = .primary.inverted
		}
		config.title = "Cancel"
		config.cornerStyle = .capsule
		config.buttonSize = .large
		self.cancelButton = UIButton(configuration: config)
		super.init(rootViewController: packView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		addButton.addTarget(self, action: #selector(add), for: .touchUpInside)
		cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
		
		packView.view.addSubview(addButton)
		packView.view.addSubview(cancelButton)
		addButton.translatesAutoresizingMaskIntoConstraints = false
		cancelButton.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			cancelButton.leadingAnchor.constraint(equalTo: packView.view.leadingAnchor, constant: 32),
			cancelButton.bottomAnchor.constraint(equalTo: packView.view.bottomAnchor, constant: -32),
			
			addButton.trailingAnchor.constraint(equalTo: packView.view.trailingAnchor, constant: -32),
			addButton.bottomAnchor.constraint(equalTo: packView.view.bottomAnchor, constant: -32),
		])
	}
	
	@objc func add() {
		emojiHoarder.addEmojiPack(packView.pack)
		emojiHoarder.sendChangeNotif(for: .packs)
		dismiss(animated: true)
	}
	
	@objc func cancel() {
		dismiss(animated: true)
	}
}
