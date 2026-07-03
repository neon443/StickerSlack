//
//  EmojiPackDetailViewRepresentable.swift
//  StickerSlack
//
//  Created by neon443 on 03/07/2026.
//

import Foundation
import UIKit
import SwiftUI

struct EmojiPackDetailViewRepresentable: UIViewControllerRepresentable {
	typealias UIViewControllerType = UINavigationController
	
	var hoarder: EmojiHoarder
	var pack: EmojiPack
	
	func makeUIViewController(context: Context) -> UINavigationController {
		let view = EmojiPackDetailViewController(with: hoarder, andPack: pack)
		view.isToolbarHidden = false
		return view
	}
	
	func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
		
	}
}
