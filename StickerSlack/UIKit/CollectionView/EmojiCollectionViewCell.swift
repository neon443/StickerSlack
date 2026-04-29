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
	let deleteButton = UIButton(type: .custom)
	var edit: Bool = false
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		label.font = .preferredFont(forTextStyle: .caption1)
		label.textAlignment = .center
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(label)
		NSLayoutConstraint.activate([
			label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
		])
		
		deleteButton.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
		deleteButton.imageView?.contentMode = .scaleAspectFit
		deleteButton.configuration = .plain()
		contentView.addSubview(deleteButton)
		deleteButton.tintColor = .systemRed
		deleteButton.clipsToBounds = false
		deleteButton.translatesAutoresizingMaskIntoConstraints = false
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
		contentView.bringSubviewToFront(deleteButton)
		
		NSLayoutConstraint.activate([
			deleteButton.topAnchor.constraint(equalTo: hostingController!.view.topAnchor, constant: -16),
			deleteButton.leadingAnchor.constraint(equalTo: hostingController!.view.leadingAnchor, constant: -16),
			deleteButton.heightAnchor.constraint(equalToConstant: 32),
			deleteButton.widthAnchor.constraint(equalToConstant: 32)
		])
	}
	
	func setEdit(to newValue: Bool) {
		self.edit = newValue
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		label.text = nil
	}
}
