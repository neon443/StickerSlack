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
	var width: CGFloat = 0
	var style: EmojiCollectionView.Style = .plain
	var onTap: (() -> Void)?
	
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
		let gestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(handleTap))
		addGestureRecognizer(gestureRecogniser)
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
	
	@objc func handleTap(sender: UITapGestureRecognizer) {
		guard sender.state == .ended else { return }
		onTap?()
		print("tap")
	}
	
	override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
		super.preferredLayoutAttributesFitting(layoutAttributes)
		guard let superview,
			  let collectionView = superview as? UICollectionView else { return layoutAttributes }
		
		let totalWidth = collectionView.bounds.width
		let availWidth = totalWidth-collectionView.contentInset.left-collectionView.contentInset.right
		var cols: CGFloat
		if style == .jumboMoji {
			cols = width
		} else {
			cols = max(1, floor(availWidth/width))
		}
		if cols == 0 || cols == .infinity { cols = 4 }
		let totalSpacing = ((collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0) * (cols-1)
		let itemWidth = ((availWidth-totalSpacing)/cols).rounded(.down)
		layoutAttributes.size = CGSize(width: itemWidth, height: itemWidth)
		return layoutAttributes
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
