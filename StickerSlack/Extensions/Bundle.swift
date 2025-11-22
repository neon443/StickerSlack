//
//  Bundle.swift
//  StickerSlack
//
//  Created by neon443 on 18/11/2025.
//

import Foundation

extension Bundle {
	var appVersion: String {
		let version = infoDictionary?["CFBundleShortVersionString"] as? String
		return version ?? "0.0"
	}
	
	var appBuild: String {
		let build = infoDictionary?["CFBundleVersion"] as? String
		return "(" + (build ?? "0") + ")"
	}
}
