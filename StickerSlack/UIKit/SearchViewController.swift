//
//  SearchViewController.swift
//  StickerSlack
//
//  Created by neon443 on 04/07/2026.
//

import Foundation
import UIKit
import SwiftUI

class SearchViewController: UINavigationController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
	var emojiHoarder: EmojiHoarder
	
	var resultsTable: EmojiTableView
	var searchController: UISearchController
	var previousQueries: [String] = []
	
	init(emojiHoarder: EmojiHoarder) {
		self.emojiHoarder = emojiHoarder
		self.resultsTable = EmojiTableView(hoarder: emojiHoarder, items: emojiHoarder.trie.allNames())
		self.searchController = UISearchController(searchResultsController: nil)
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setViewControllers([resultsTable], animated: true)
		
		resultsTable.navigationItem.title = "Search"
		
		searchController.delegate = self
		searchController.searchResultsUpdater = self
		
		searchController.searchBar.autocapitalizationType = .none
		searchController.searchBar.delegate = self
		searchController.hidesNavigationBarDuringPresentation = false
		resultsTable.navigationItem.hidesSearchBarWhenScrolling = false
		
		resultsTable.navigationItem.searchController = searchController
		resultsTable.navigationItem.hidesBackButton = false
		definesPresentationContext = true
	}
	
	func updateSearchResults(for searchController: UISearchController) {
		guard let text = searchController.searchBar.text else { return }
		guard !text.isEmpty else { return }
		
		let previousQuery: String?
		if previousQueries.count > 1 {
			previousQuery = previousQueries[previousQueries.count-2]
		} else { previousQuery = nil }
		
		let results = emojiHoarder.trie.search(
			for: text,
			previousQuery: previousQuery,
			previousResult: Set(resultsTable.items)
		)
		
		resultsTable.refreshUI(with: results)
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		guard !searchText.isEmpty else {
			previousQueries = []
			return
		}
		previousQueries.append(searchText)
		print(previousQueries)
	}
}
