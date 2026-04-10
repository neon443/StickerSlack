//
//  EmojiCell.swift
//  StickerSlack
//
//  Created by neon443 on 11/04/2026.
//

import Foundation
import UIKit
import SwiftUI

class EmojiCell: UITableViewCell {
	private var spinner: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
	private var hostingController: UIHostingController<StickerRow<EmojiHoarder>>?
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		spinner.startAnimating()
		spinner.frame = frame
		addSubview(spinner)
		
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
	
	func configure(with hoarder: EmojiHoarder, emoji: Emoji) {
		let swiftUIView = StickerRow(hoarder: hoarder, sticker: emoji)
		spinner.removeFromSuperview()
		
		if let hostingController {
			hostingController.rootView = swiftUIView
		} else {
			let controller = UIHostingController(rootView: swiftUIView)
			hostingController = controller
			contentView.addSubview(controller.view)
			
			controller.view.translatesAutoresizingMaskIntoConstraints = false
			NSLayoutConstraint.activate([
				controller.view.topAnchor.constraint(equalTo: contentView.topAnchor),
				controller.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
				controller.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
				controller.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
			])
		}
	}
	
	override func prepareForReuse() {
		spinner.removeFromSuperview()
		super.prepareForReuse()
	}
}
