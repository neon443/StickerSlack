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
	var view: UIKitGifView = UIKitGifView(image: nil)
	var hostingController: UIHostingController<StickerPreview>?
	var imageLoadTask: Task<Void, Never>?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		view.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(view)
		NSLayoutConstraint.activate([
			view.topAnchor.constraint(equalTo: contentView.topAnchor),
			view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			view.heightAnchor.constraint(equalTo: view.widthAnchor),
		])
		addGestureRecognizer(UITapGestureRecognizer())
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configureSkeleton() {
	}
	
	func configure(with: EmojiHoarder, emoji: Emoji) {
		imageLoadTask?.cancel()
		view.image = nil
		imageLoadTask = Task { [weak self] in
			await self?.view.configure(with: emoji)
		}
//		hostingController?.view.removeFromSuperview()
//		let swiftUIView = StickerPreview(sticker: emoji)
//		
//		let hostingController = UIHostingController(rootView: swiftUIView)
//		self.hostingController = hostingController
//		contentView.addSubview(hostingController.view)
//		
//		hostingController.view.translatesAutoresizingMaskIntoConstraints = false
//		NSLayoutConstraint.activate([
//			hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
//			hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//			hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//			hostingController.view.heightAnchor.constraint(equalTo: hostingController.view.widthAnchor),
//		])
	}
	
	func handleTap(sender: UITapGestureRecognizer) {
		guard sender.state == .ended else { return }
		print("tap")
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		imageLoadTask?.cancel()
		imageLoadTask = nil
		self.view.image = nil
		
		hostingController?.view.removeFromSuperview()
		hostingController = nil
		
		configureSkeleton()
	}
}
