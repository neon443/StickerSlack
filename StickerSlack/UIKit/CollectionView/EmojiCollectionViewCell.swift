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
	let spacer = UIView()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		contentView.addSubview(spacer)
		spacer.translatesAutoresizingMaskIntoConstraints = false
		
		label.font = .preferredFont(forTextStyle: .caption1)
		label.textAlignment = .center
		label.numberOfLines = 0
		contentView.addSubview(label)
		label.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			spacer.topAnchor.constraint(equalTo: topAnchor),
			spacer.bottomAnchor.constraint(equalTo: label.topAnchor),
			spacer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			spacer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			
			label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
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
		setNeedsLayout()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		label.text = nil
	}
}
