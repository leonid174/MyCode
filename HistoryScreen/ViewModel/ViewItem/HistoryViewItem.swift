//
//  HistoryViewItem.swift
//
//  Created by Leonid Vilner on 23.02.2022.
//

import Foundation
import Combine

struct HistoryHeaderItem: Hashable {
    let title: String
}

struct HistoryItem: Hashable {
    
    enum BalanceState: Hashable {
        case balanced
        case high
        case low
        case off
    }
    
    let sectionIdentifier: String
    let value: Int
    let maxValue: Int
    let date: Date
    let dateFormatter: DateFormatter
    let isBalanced: BalanceState?
}
