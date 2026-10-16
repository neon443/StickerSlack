//
//  MessagesToolbarView.swift
//  StickerSlack
//
//  Created by neon443 on 15/10/2026.
//

import UIKit

class MessagesToolbarView: UIStackView {
	var labelView: UIVisualEffectView
	var labelTitle: UILabel
	var labelSubTitle: UILabel
	
	var goView: UIVisualEffectView
	var goButton: UIButton
	
	init() {
		self.labelTitle = UILabel()
		self.labelSubTitle = UILabel()
		self.labelView = UIVisualEffectView(effect: nil)
		var effect: UIVisualEffect
		if #available(iOS 19, *) {
			let glassEffect = UIGlassEffect()
			glassEffect.isInteractive = true
			effect = glassEffect
		} else {
			effect = UIBlurEffect(style: .systemThinMaterial)
		}
		labelView.effect = effect
		
		self.goView = UIVisualEffectView(effect: nil)
		var effect2: UIVisualEffect
		if #available(iOS 19, *) {
			let glassEffect = UIGlassEffect()
			glassEffect.isInteractive = true
			glassEffect.tintColor = .accent
			effect2 = glassEffect
		} else {
			effect2 = UIBlurEffect(style: .systemThinMaterial)
		}
		goView.effect = effect2
		
		self.goButton = UIButton(type: .custom)
		
		super.init(frame: .zero)
		
		setup()
		refreshUI()
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setup() {
		self.axis = .horizontal
		self.spacing = 4
		
		let labelStack = UIStackView(arrangedSubviews: [labelTitle, labelSubTitle])
		labelView.layer.masksToBounds = true
		labelStack.axis = .vertical
		labelStack.insetsLayoutMarginsFromSafeArea = false
		labelStack.layoutMargins = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
		labelStack.isLayoutMarginsRelativeArrangement = true
		labelView.contentView.addSubview(labelStack)
		labelStack.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			labelStack.heightAnchor.constraint(equalTo: labelView.heightAnchor),
			labelStack.widthAnchor.constraint(equalTo: labelView.widthAnchor)
		])
		
		labelTitle.textAlignment = .center
		labelTitle.font = .preferredFont(forTextStyle: .subheadline)
		labelSubTitle.textAlignment = .center
		labelSubTitle.font = .preferredFont(forTextStyle: .caption1)
		
		
		goButton.layer.masksToBounds = true
		goButton.setImage(UIImage(named: "arrow.up.right.square"), for: .normal)
		goView.addSubview(goButton)
		goButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			goButton.widthAnchor.constraint(equalTo: goView.widthAnchor),
			goButton.heightAnchor.constraint(equalTo: goView.heightAnchor)
		])
		
		self.addArrangedSubview(labelView)
		self.addArrangedSubview(goView)
	}
	
	func refreshUI() {
		
	}
}
