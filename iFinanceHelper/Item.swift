//
//  Item.swift
//  iFinanceHelper
//
//  Created by Vlad on 13/03/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
