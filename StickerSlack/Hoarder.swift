//
//  Hoarder.swift
//  StickerSlack
//
//  Created by neon443 on 10/03/2026.
//

import Foundation
import SwiftUI
import Combine
import UniformTypeIdentifiers

protocol Hoarder {
	static var container: URL { get }
	var endpoint: URL { get }
	var encoder: JSONEncoder { get }
	var decoder: JSONDecoder { get }
	var searchTerm: String { get set }
}

extension Hoarder {
	static var container: URL { FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.neon443.StickerSlack")!.appendingPathComponent("Library", conformingTo: .directory)
	}
	
	var encoder: JSONEncoder { JSONEncoder() }
	var decoder: JSONDecoder { JSONDecoder() }
}
