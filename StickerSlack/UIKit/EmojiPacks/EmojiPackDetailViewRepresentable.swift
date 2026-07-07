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
	var hoarder: EmojiHoarder
	var pack: EmojiPack
	
	func makeUIViewController(context: Context) -> UIViewController {
		let view = EmojiPackDetailViewController(with: hoarder, andPack: pack)
		return view
	}
	
	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
		
	}
}
