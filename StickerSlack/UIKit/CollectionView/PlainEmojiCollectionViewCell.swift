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
	let spinner = UIActivityIndicatorView()
	var hostingController: UIHostingController<StickerPreview>?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configureSkeleton() {
		spinner.frame = frame
		spinner.startAnimating()
		self.contentView.addSubview(spinner)
		
		spinner.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			spinner.topAnchor.constraint(equalTo: contentView.topAnchor),
			spinner.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			spinner.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			spinner.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
		])
		
	}
	
	func configure(with: EmojiHoarder, emoji: Emoji) {
		let swiftUIView = StickerPreview(sticker: emoji)
		
		if let hostingController {
			hostingController.rootView = swiftUIView
		} else {
			let hostingController = UIHostingController(rootView: swiftUIView)
			self.hostingController = hostingController
			self.contentView.addSubview(hostingController.view)
			
			hostingController.view.translatesAutoresizingMaskIntoConstraints = false
			NSLayoutConstraint.activate(
				[
					hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
//					hostingController.view.bottomAnchor.constraint(equalTo: contentView.topAnchor, ),
					hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
					hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
					hostingController.view.heightAnchor.constraint(equalTo: hostingController.view.widthAnchor)
				]
			)
		}
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		hostingController?.view.removeFromSuperview()
		hostingController = nil
		if spinner.superview == nil {
			configureSkeleton()
		}
		spinner.startAnimating()
	}
}
