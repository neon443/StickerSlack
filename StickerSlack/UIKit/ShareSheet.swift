//
//  ShareSheet.swift
//  StickerSlack
//
//  Created by neon443 on 10/04/2026.
//

import Foundation
import UIKit
import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
	let activityItems: [Any]
	let applicationActivities: [UIActivity]? = nil
	
	func makeUIViewController(context: Context) -> UIActivityViewController {
		let controller = UIActivityViewController(
			activityItems: activityItems,
			applicationActivities: applicationActivities
		)
		return controller
	}
	
	func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
//		<#code#>
	}
}
