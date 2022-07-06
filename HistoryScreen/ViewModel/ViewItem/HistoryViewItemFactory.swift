//
//  HistoryViewItemFactory.swift
//
//  Created by Leonid Vilner on 23.02.2022.
//

import Foundation

final class HistoryViewItemFactory {

    private let valueRange: [HistoryItem.BalanceState: ClosedRange<Int>] = [
        .off: 0...0,
        .low: 1...5,
        .balanced: 6...7,
        .high: 8...11
    ]

    private func isBalancedValue(_ value: Int) -> HistoryItem.BalanceState {
        valueRange.first { $0.value.contains(value) }?.key ?? .off
    }
}

extension HistoryViewItemFactory {
    func make(fromElement element: HistoryElement, scale: HistoryTimeScale) -> HistoryItem {
        .init(
            sectionIdentifier: makeIdentifier(date: element.date, scale: scale),
            value: element.value ?? 0,
            maxValue: element.maxValue,
            date: element.date,
            dateFormatter: {
                let formatter = DateFormatter()
                formatter.calendar = .current
                formatter.locale = .current
                formatter.timeZone = .current
                switch scale {
                    case .days: formatter.dateFormat = "dd MMM"
                    case .hours: formatter.dateFormat = "HH:00"
                    case .months: formatter.dateFormat = "MMM"
                }
                return formatter
            }(),
            isBalanced: isBalancedValue(element.value ?? 0)
        )
    }
    func makeIdentifier(date: Date, scale: HistoryTimeScale) -> String {
        let formatter = DateFormatter()
        switch scale {
        case .days:
            formatter.dateFormat = "MMM"
        case .hours:
            formatter.dateFormat = "dd E"
        case .months:
            formatter.dateFormat = "yyyy"
        }
        return formatter.string(from: date)
    }
}
