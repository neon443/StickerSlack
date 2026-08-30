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
	var edit: Bool = false
	var onRemove: ((String) -> Void)?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		label.font = .preferredFont(forTextStyle: .caption1)
		label.textAlignment = .center
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(label)
		
		button.alpha = 0
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
			label.topAnchor.constraint(equalTo: self.view.bottomAnchor),
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
	
	func setEdit(to editing: Bool, animated: Bool = true) {
		self.edit = editing
		button.isEnabled = editing
		button.isUserInteractionEnabled = editing
		
		let changes = {
			self.button.alpha = editing ? 1 : 0
		}
		
		if animated {
			UIView.animate(withDuration: 0.2, animations: changes)
		} else {
			changes()
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
	
	override func preferredItemSize(for width: CGFloat) -> CGSize {
		guard label.text != nil else { return super.preferredItemSize(for: width) }
		let labelHeight = label.sizeThatFits(CGSize(width: width, height: .infinity)).height
		return CGSize(width: width, height: width + 4 + labelHeight)
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		label.text = nil
		onRemove = nil
		button.alpha = 0
		button.isEnabled = false
		button.isUserInteractionEnabled = false
		edit = false
	}
	
	override func dragStateDidChange(_ dragState: UICollectionViewCell.DragState) {
		self.transform = .identity
		
		switch dragState {
		case .none:
			self.setEdit(to: edit, animated: false)
		case .lifting:
			button.alpha = 0
		case .dragging:
			button.alpha = 0
		@unknown default:
			fatalError()
		}
	}
}
