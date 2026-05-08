//
//  EmojiCollectionViewCell.swift
//  StickerSlack
//
//  Created by neon443 on 26/04/2026.
//

import Foundation
import UIKit
import SwiftUI

class EmojiCollectionViewCell: PlainEmojiCollectionViewCell {
	let label = UILabel()
	let button = UIButton(type: .custom)
	var edit: Bool?
	var onRemove: ((String) -> Void)?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		label.font = .preferredFont(forTextStyle: .caption1)
		label.textAlignment = .center
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(label)
		
		button.alpha = 0
		button.isHidden = true
		button.isEnabled = false
		button.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
		button.imageView?.contentMode = .scaleAspectFit
		button.contentHorizontalAlignment = .fill
		button.contentVerticalAlignment = .fill
		button.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
		button.tintColor = .systemRed
		button.clipsToBounds = false
		button.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(button)
		
		NSLayoutConstraint.activate([
			label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			
			button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -12),
			button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -12),
			button.heightAnchor.constraint(equalToConstant: 24),
			button.widthAnchor.constraint(equalToConstant: 24)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func configureSkeleton() {
		super.configureSkeleton()
	}
	
	override func configure(with: EmojiHoarder, emoji: Emoji) {
		super.configure(with: with, emoji: emoji)
		label.text = emoji.UIName
		contentView.bringSubviewToFront(button)
	}
	
	func setEdit(to newValue: Bool?) {
		self.edit = newValue
		if edit ?? false {
			contentView.bringSubviewToFront(button)
			self.button.isHidden = false
			button.isEnabled = true
			UIView.animate(withDuration: 0.2) {
				self.button.alpha = 1
			}
		} else {
			UIView.animate(withDuration: 0.2) {
				self.button.alpha = 0
			} completion: { _ in
				self.button.isHidden = true
				self.button.isEnabled = false
			}
		}
	}
	
	@objc
	func deleteTapped() {
		if let emojiName = label.text {
			onRemove?(emojiName)
		}
	}
	
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let expandedBounds = bounds.insetBy(
			dx: -button.bounds.width/2,
			dy: -button.bounds.height/2,
		)
		if expandedBounds.contains(point) {
			let buttonPoint = convert(point, to: button)
			if button.bounds.contains(buttonPoint) {
				return button
			}
		}
		return super.hitTest(point, with: event)
	}
	
	override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
		let layoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
		guard label.text != nil else { return layoutAttributes }
		let labelHeight = label.sizeThatFits(CGSize(width: layoutAttributes.size.width, height: .infinity)).height
		layoutAttributes.size = CGSize(width: layoutAttributes.size.width, height: labelHeight+4+view.frame.height)
		print(label.text!, layoutAttributes.size)
		return layoutAttributes
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		label.text = nil
		setEdit(to: edit)
	}
}
