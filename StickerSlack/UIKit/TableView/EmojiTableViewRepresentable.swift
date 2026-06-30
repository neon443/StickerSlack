//
//  EmojiTableView.swift
//  StickerSlack
//
//  Created by neon443 on 03/11/2025.
//

import Foundation
import UIKit
import SwiftUI
import Haptics

struct EmojiTableViewRepresentable: UIViewRepresentable {
	let hoarder: EmojiHoarder
	let items: [String]
	
	func makeUIView(context: Context) -> UITableView {
		let tableView = context.coordinator as UITableViewController
		return tableView.tableView
	}
	
	func updateUIView(_ uiView: UITableView, context: Context) {
		context.coordinator.hoarder = hoarder
		context.coordinator.refreshUI(with: items)
	}
	
	func makeCoordinator() -> EmojiTableView {
		return EmojiTableView(hoarder: hoarder, items: items)
	}
}
