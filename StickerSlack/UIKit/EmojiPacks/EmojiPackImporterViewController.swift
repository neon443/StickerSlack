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
	var pack: EmojiPack
	var packView: EmojiPackDetailViewController
	
	init(emojiHoarder: EmojiHoarder, pack: EmojiPack) {
		self.emojiHoarder = emojiHoarder
		self.pack = pack
		self.packView = EmojiPackDetailViewController(with: emojiHoarder, andPack: pack)
		super.init(rootViewController: packView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		packView.navigationItem.title = "Shared Pack"
	}
}
