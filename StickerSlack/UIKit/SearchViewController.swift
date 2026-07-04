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
	
	var resultsView: EmojiTableView
	var searchController: UISearchController
	var previousQueries: [String] = []
	
	var noResultsView = UIHostingController(
		rootView: EmptyCollectionView(
			title: "No Results",
			details: "Try searching for something else",
			systemImage: "magnifyingglass"
		)
	)
	
	init(emojiHoarder: EmojiHoarder) {
		self.emojiHoarder = emojiHoarder
		self.resultsView = EmojiTableView(hoarder: emojiHoarder, items: emojiHoarder.trie.allNames())
		self.searchController = UISearchController(searchResultsController: nil)
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setViewControllers([resultsView], animated: true)
		
		resultsView.navigationItem.title = "Search"
		
		searchController.delegate = self
		searchController.searchResultsUpdater = self
		
		searchController.searchBar.autocapitalizationType = .none
		searchController.searchBar.delegate = self
		searchController.hidesNavigationBarDuringPresentation = false
		resultsView.navigationItem.hidesSearchBarWhenScrolling = false
		
		resultsView.navigationItem.searchController = searchController
		resultsView.navigationItem.hidesBackButton = false
		definesPresentationContext = true
		
		noResultsView.view.transform = CGAffineTransform(scaleX: 0, y: 0)
		resultsView.addChild(noResultsView)
		resultsView.view.addSubview(noResultsView.view)
		noResultsView.view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			resultsView.view.leadingAnchor.constraint(equalTo: noResultsView.view.leadingAnchor),
			resultsView.view.trailingAnchor.constraint(equalTo: noResultsView.view.trailingAnchor),
			resultsView.view.topAnchor.constraint(equalTo: noResultsView.view.topAnchor),
			resultsView.view.bottomAnchor.constraint(equalTo: noResultsView.view.topAnchor, constant: 100)
		])
		noResultsView.didMove(toParent: self)
	}
	
	func reset() {
		previousQueries = []
		resultsView.refreshUI(with: [])
		self.noResultsView.view.transform = CGAffineTransform(scaleX: 0, y: 0)
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
			previousResult: Set(resultsView.items)
		)
		
		if results.isEmpty {
			UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1) {
				self.noResultsView.view.transform = .identity
			}
		} else {
			UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1) {
				self.noResultsView.view.transform = CGAffineTransform(scaleX: 0, y: 0)
			}
		}
		resultsView.refreshUI(with: results)
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		guard !searchText.isEmpty else {
			reset()
			return
		}
		previousQueries.append(searchText)
		print(previousQueries)
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		reset()
	}
}
