//
//  EmojiCollectionViewCell.swift
//  StickerSlack
//
//  Created by neon443 on 24/04/2026.
//

import Foundation
import UIKit
import SwiftUI

class EmojiCollectionViewCell: UICollectionViewCell {
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		let spinner = UIActivityIndicatorView()
		spinner.frame = frame
		spinner.startAnimating()
		self.contentView.addSubview(spinner)
		spinner.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			spinner.topAnchor.constraint(equalTo: contentView.topAnchor),
			spinner.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			spinner.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			spinner.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
