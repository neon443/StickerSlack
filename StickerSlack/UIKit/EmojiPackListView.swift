//
//  EmojiPackListView.swift
//  StickerSlack
//
//  Created by neon443 on 05/07/2026.
//

import Foundation
import UIKit

class EmojiPackListView: UITableViewController {
	var emojiHoarder: EmojiHoarder
	
	init(emojiHoarder: EmojiHoarder) {
		self.emojiHoarder = emojiHoarder
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return emojiHoarder.emojiPacks.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		var content = cell.defaultContentConfiguration()
		guard indexPath.row+1 <= emojiHoarder.emojiPacks.count else { return cell }
		let pack = emojiHoarder.emojiPacks[indexPath.row]
		
		content.text = pack.name
		content.secondaryText = "\(pack.items.count) item\(pack.items.count.plural)"
		
		cell.contentConfiguration = content
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard indexPath.row+1 <= emojiHoarder.emojiPacks.count else { return }
		let pack = emojiHoarder.emojiPacks[indexPath.row]
		
		print(indexPath)
		
		let detailView = EmojiPackDetailViewController(with: emojiHoarder, andPack: pack)
		
		super.navigationController?.pushViewController(detailView.collectionView, animated: true)
	}
}
