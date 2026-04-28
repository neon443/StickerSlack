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
//	let spinner = UIActivityIndicatorView()
	var hostingController: UIHostingController<StickerPreview>?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		stackView.axis = .vertical
		stackView.alignment = .fill
		stackView.distribution = .fill
		stackView.spacing = 4
		
		contentView.addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configureSkeleton() {
//		spinner.startAnimating()
//		if spinner.superview == nil {
//			stackView.addArrangedSubview(spinner)
//		}
	}
	
	func configure(with: EmojiHoarder, emoji: Emoji) {
		hostingController?.view.removeFromSuperview()
		let swiftUIView = StickerPreview(sticker: emoji)
		
//		if let hostingController {
//			hostingController.rootView = swiftUIView
//		} else {
			let hostingController = UIHostingController(rootView: swiftUIView)
			self.hostingController = hostingController
			self.stackView.insertArrangedSubview(hostingController.view, at: 0)
			
			hostingController.view.translatesAutoresizingMaskIntoConstraints = false
			NSLayoutConstraint.activate([
				hostingController.view.heightAnchor.constraint(equalTo: hostingController.view.widthAnchor)
			])
//		}
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
//		stackView.arrangedSubviews.forEach {
//			stackView.removeArrangedSubview($0)
//			$0.removeFromSuperview()
//		}
		
		hostingController?.view.removeFromSuperview()
		hostingController = nil
		
		configureSkeleton()
	}
}
