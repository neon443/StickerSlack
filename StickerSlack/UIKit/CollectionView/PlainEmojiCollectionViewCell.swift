//
//  PlainEmojiCollectionViewCell.swift
//  StickerSlack
//
//  Created by neon443 on 24/04/2026.
//

import Foundation
import UIKit
import SwiftUI

class PlainEmojiCollectionViewCell: UICollectionViewCell {
	var hostingController: UIHostingController<StickerPreview>?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configureSkeleton() {
	}
	
	func configure(with: EmojiHoarder, emoji: Emoji) {
		hostingController?.view.removeFromSuperview()
		let swiftUIView = StickerPreview(sticker: emoji)
		
		let hostingController = UIHostingController(rootView: swiftUIView)
		self.hostingController = hostingController
		contentView.addSubview(hostingController.view)
		
		hostingController.view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
			hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
		])
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		hostingController?.view.removeFromSuperview()
		hostingController = nil
		
		configureSkeleton()
	}
}
