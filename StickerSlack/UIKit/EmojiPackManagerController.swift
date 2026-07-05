//
//  EmojiPackManagerController.swift
//  StickerSlack
//
//  Created by neon443 on 05/07/2026.
//

import Foundation
import UIKit

class EmojiPackManagerController: UINavigationController {
	var emojiHoarder: EmojiHoarder
	
	
	init(emojiHoarder: EmojiHoarder) {
		self.emojiHoarder = emojiHoarder
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
}
