//
//  Url-Utils.swift
//  chinese_clip
//
//  Created by Yixuan Si on 5/30/24.
//

import Foundation
import SwiftUI

extension URL {
    static func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else {
            return false
        }
        return true
    }
}
