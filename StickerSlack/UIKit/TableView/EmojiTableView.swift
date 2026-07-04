//
//  EmojiTableView.swift
//  StickerSlack
//
//  Created by neon443 on 03/11/2025.
//

import Foundation
import UIKit

final class EmojiTableView: UITableViewController {
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
		tableView.register(EmojiTableViewCell.self, forCellReuseIdentifier: "cell")
		self.refreshUI(with: items)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func refreshUI(with newItems: [String]) {
		let itemsBefore = self.items
		let itemsAfter = newItems
		self.items = newItems
		Task.detached {
			//if its being cleared or removign 10k+
			if itemsAfter.isEmpty {
				await self.instantApplySnapshot()
				return
			}
			if itemsAfter.count > 10_000 {
				await self.instantApplySnapshot()
				return
			}
//			guard !itemsAfter.isEmpty && itemsBefore.count-itemsAfter.count < 10_000 else {
//				await self.instantApplySnapshot()
//				return
//			}
			await self.applySnapshot(animated: true)
		}
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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
		if #available(iOS 10, *) {
			tableView.refreshControl = refreshControl
		} else {
			tableView.backgroundView = refreshControl
		}
	}
	
	@objc func refresh(_ refreshControl: UIRefreshControl) {
		hoarder.startLoading(localOnly: false, skipIndex: false)
		refreshControl.endRefreshing()
		
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
