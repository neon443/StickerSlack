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
	let stackView = UIStackView()
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
		self.contentView.addSubview(stackView)
		stackView.addArrangedSubview(spinner)
		
		stackView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
		])
		
	}
	
	func configure(with: EmojiHoarder, emoji: Emoji) {
		let swiftUIView = StickerPreview(sticker: emoji)
		
		if let hostingController {
			hostingController.rootView = swiftUIView
		} else {
			let hostingController = UIHostingController(rootView: swiftUIView)
			self.hostingController = hostingController
			self.stackView.addArrangedSubview(hostingController.view)
			
			hostingController.view.translatesAutoresizingMaskIntoConstraints = false
			NSLayoutConstraint.activate(
				[
					hostingController.view.topAnchor.constraint(equalTo: stackView.topAnchor),
					hostingController.view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
					hostingController.view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
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
