//
//  JumboMoji.swift
//  StickerSlack
//
//  Created by neon443 on 03/05/2026.
//

import Foundation
import CoreGraphics

struct JumboMoji: CustomStringConvertible, Hashable {
	var baseName: String
	var width: Int
	var height: Int
	var type: JumboMoji.Style
	var items: [String]
	
	var description: String {
		self.baseName + " " + "\(width)x\(height)"
	}
	
	init(baseName: String, items: [String]) {
		fatalError()
		let itemsBaseNameRemoved = items.map { String($0.dropFirst(baseName.count+1)) }
		var coordinates: [(Int, Int)] = []
		for item in itemsBaseNameRemoved {
			let split = item.dropLast(item.split(separator: "-").last?.count ?? 0)
			print(split)
		}
		self.width = 0
		self.height = 0
		self.baseName = baseName
		self.type = .grid
		self.items = items
	}
	
	init?(components: [JumboMoji.Components]) {
		guard components.allSatisfy({$0.baseName == components.first?.baseName}) else { return nil }
		self.baseName = components.first!.baseName
		
		let coords = components.map { CGPoint(x: $0.x, y: $0.y) }
		guard let width = Int(coords.sorted { $0.x > $1.x }.first?.x.formatted() ?? "") else { return nil }
		self.width = width
		guard let height = Int(coords.sorted { $0.y > $1.y }.first?.y.formatted() ?? "") else { return nil }
		self.height = height
		
		self.type = .grid
		self.items = components.map { "\($0.baseName)-\($0.coordinate)-\($0.id)-" }
	}
	
	enum Style {
		case grid
		case btn
	}
	
	static func from(names input: [String]) -> [JumboMoji] {
		guard input.count > 0 else { return [] }
		let input = input.sorted()
		
		var jumboMojiComponents: [String: [JumboMoji.Components]] = [:]
		for i in input.indices {
			guard let currentComponents = splitIntoComponents(string: input[i]) else { continue }
			
			if jumboMojiComponents.isEmpty || jumboMojiComponents[currentComponents.baseName] == nil {
				jumboMojiComponents[currentComponents.baseName] = [currentComponents]
			} else {
				jumboMojiComponents[currentComponents.baseName]?.append(currentComponents)
			}
		}
		
		print(jumboMojiComponents.mapValues({JumboMoji(components: $0)}).count)
		var result: [JumboMoji] = []
		for item in jumboMojiComponents {
			if let jumbomoji = JumboMoji(components: item.value) {
				result.append(jumbomoji)
			}
		}
		return result
	}
	
	static func splitIntoComponents(string input: String) -> JumboMoji.Components? {
		var string = input
		
		var baseNameCount: Int = -1
		for char in string {
			if Int(String(char)) == nil {
				baseNameCount += 1
			} else { break }
		}
		guard baseNameCount > -1 && baseNameCount != input.count else { return nil }
		let baseName = String(input.prefix(baseNameCount))
		string = String(string.dropFirst(baseName.count+1))
		guard input.dropFirst(baseNameCount).first == "-" else { return nil }
		
		var coordCount = 1
		var freeSkip = 1
		for char in string {
			if Int(String(char)) == nil {
				guard freeSkip > 0 else { break }
				freeSkip -= 1
				continue
			} else {
				coordCount += 1
			}
		}
		let coord = String(string.prefix(coordCount))
		let coordSplit = coord.split(separator: "-").map { String($0) }
		guard coord.contains("-") &&
				Int(coordSplit.first ?? "x") != nil &&
				Int(coordSplit.last ?? "x") != nil
		else { return nil }
		string = String(string.dropFirst(coordCount+1))
		
		let id = string
		
		return JumboMoji.Components(
			baseName: baseName,
			coordinate: coord,
			id: id
		)
	}
	
	struct Components {
		var baseName: String
		var coordinate: String
		var x: Int {
			let split = coordinate.split(separator: "-").first ?? "0"
			return Int(split) ?? 0
		}
		var y: Int {
			let split = coordinate.split(separator: "-").last ?? "0"
			return Int(split) ?? 0
		}
		var id: String
	}
}
