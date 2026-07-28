//
//  MessagesRootViewController.swift
//  StickerSlackiMessageApp
//
//  Created by neon443 on 29/07/2026.
//

import Foundation
import UIKit
import Messages

class MessagesRootViewController: UIViewController {
	let leadingVC: UIViewController
	let trailingVC: UIViewController
	
	init(leading: UIViewController, trailing: UIViewController) {
		self.leadingVC = leading
		self.trailingVC = trailing
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		addChild(leadingVC)
		addChild(trailingVC)
		
		view.addSubview(leadingVC.view)
		view.addSubview(trailingVC.view)
		
		leadingVC.view.translatesAutoresizingMaskIntoConstraints = false
		trailingVC.view.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			leadingVC.view.topAnchor.constraint(equalTo: view.topAnchor),
			leadingVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			leadingVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			leadingVC.view.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width*0.25),
			
			trailingVC.view.topAnchor.constraint(equalTo: view.topAnchor),
			trailingVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			trailingVC.view.leadingAnchor.constraint(equalTo: leadingVC.view.leadingAnchor),
			trailingVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])
		
		leadingVC.didMove(toParent: self)
		trailingVC.didMove(toParent: self)
	}
}
