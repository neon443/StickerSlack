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

struct EmojiTableView: UIViewRepresentable {
	let hoarder: EmojiHoarder
	let items: [String]
	
	func makeUIView(context: Context) -> UITableView {
		let tableView = context.coordinator as UITableViewController
		tableView.tableView.register(EmojiTableViewCell.self, forCellReuseIdentifier: "cell")
		return tableView.tableView
	}
	
	func updateUIView(_ uiView: UITableView, context: Context) {
		context.coordinator.hoarder = hoarder
		
		let itemsBefore = context.coordinator.items
		let itemsAfter = items
		context.coordinator.items = items
//		guard itemsBefore != itemsAfter else { return }
		Task.detached {
			if !(-10_000...10_000).contains(itemsBefore.count-itemsAfter.count) {
				//diff of more than 10k
				await context.coordinator.instantApplySnapshot()
			} else if itemsAfter == itemsBefore {
				await context.coordinator.instantApplySnapshot()
			} else {
				await context.coordinator.applySnapshot(animated: true)
			}
		}
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(hoarder: hoarder, items: items)
	}
	
	final class Coordinator: UITableViewController {
		var dataSource: UITableViewDiffableDataSource<Int, String>!
		var hoarder: EmojiHoarder
		var items: [String]
		
		init(hoarder: EmojiHoarder, items: [String]) {
			self.hoarder = hoarder
			self.items = items
			super.init(style: .plain)
			self.dataSource = UITableViewDiffableDataSource<Int, String>(tableView: tableView) { (tableView: UITableView, indexPath: IndexPath, itemIdentifier: String) -> UITableViewCell? in
				return self.cell(tableView, indexPath: indexPath, forItemIdentifier: itemIdentifier)
			}
			tableView.dataSource = dataSource
		}
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		func makeSnapshot() -> NSDiffableDataSourceSnapshot<Int, String> {
			var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
			snapshot.appendSections([0])
			snapshot.appendItems(items, toSection: 0)
			return snapshot
		}
		
		func applySnapshot(animated: Bool) async {
			let snapshot = makeSnapshot()
			await (self.tableView.dataSource as! UITableViewDiffableDataSource).apply(snapshot, animatingDifferences: animated)
		}
		
		func instantApplySnapshot() async {
			let snapshot = makeSnapshot()
			await (self.tableView.dataSource as! UITableViewDiffableDataSource).applySnapshotUsingReloadData(snapshot)
		}
		
		func cell(
			_ tableView: UITableView,
			indexPath: IndexPath,
			forItemIdentifier itemIdentifier: String
		) -> UITableViewCell {
			let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EmojiTableViewCell
			cell.selectionStyle = .none
			
			guard !hoarder.trie.dict.isEmpty else { return cell }
			
			guard let emoji = hoarder.trie.dict[itemIdentifier] else { return cell }
			
			cell.configure(with: hoarder, emoji: emoji)
			return cell
		}
		
		override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
			return items.count
		}
		
		override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//			<#code#>
		}
		
		override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//			<#code#>
		}
		
		override func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
			return true
		}
	}
}
