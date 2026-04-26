//
//  EmojiCollectionViewCell.swift
//  StickerSlack
//
//  Created by neon443 on 26/04/2026.
//

import Foundation
import UIKit

class EmojiCollectionViewCell: PlainEmojiCollectionViewCell {
	let label = UILabel()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		label.font = .preferredFont(forTextStyle: .caption1)
		label.textAlignment = .center
		contentView.addSubview(label)
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
		setNeedsLayout()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		label.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
		])
		
//		label.frame = contentView.bounds
		contentView.bringSubviewToFront(label)
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		label.text = nil
	}
}
