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
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		label.font = .preferredFont(forTextStyle: .caption1)
		label.textAlignment = .center
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
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
		
		if label.superview == nil {
			stackView.addArrangedSubview(label)
		}
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		label.text = nil
	}
}
