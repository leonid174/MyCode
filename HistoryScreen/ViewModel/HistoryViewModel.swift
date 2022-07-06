//
//  HistoryViewModel.swift
//
//  Created by Leonid Vilner on 23.02.2022.
//

import Foundation
import UIKit
import Combine

enum HistoryTimeScale: Equatable {
    case days
    case hours
    case months
}

class HistoryViewModel {

    let possibleScales: [HistoryTimeScale] = [.months, .days, .hours]

    var timeScale: HistoryTimeScale
    
    private var cancelSet: Set<AnyCancellable> = []
    
    init(scale: HistoryTimeScale) {
        self.timeScale = scale
    }
}

extension HistoryViewModel {
    
    func stateBannerColors(state: HistoryItem.BalanceState) -> [CGColor] {
        switch state {
        case .off, .low:
            return [
                UIColor.init(hexString: "#FDC1A8").cgColor,
                UIColor.init(hexString: "#F7F8E6").cgColor
            ]
        case .balanced:
            return [
                UIColor.init(hexString: "#F0F8E6").cgColor,
                UIColor.init(hexString: "#F7F8E6").cgColor
            ]
        case .high:
            return [
                UIColor.init(hexString: "#E9FAFB").cgColor,
                UIColor.init(hexString: "#E9FAFB").cgColor
            ]
        }
    }
    
    func stateBannerText() -> String {
        switch timeScale {
            case .days:
                return "Your air for a month"
            case .hours:
                return "Your air for a day"
            case .months:
                return "Your air for in a year"
        }
    }
    
    func averageFromArray() -> Int {
        
        return 4
    }
}
