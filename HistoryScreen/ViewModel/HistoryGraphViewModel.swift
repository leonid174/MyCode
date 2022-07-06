//
//  HistoryGraphViewModel.swift
//  Altos-app
//
//  Created by Leonid Vilner on 09.03.2022.
//

import Foundation

class HistoryGraphViewModel {
    
    struct SectionItem {
        var identifier: String
        var cellItems: [HistoryItem]
    }
    
    private let timeScale: HistoryTimeScale
    private let cellsFactory: HistoryViewItemFactory = .init()
    
    let header: HistoryHeaderItem = .init(title: UUID().uuidString)
    var cells: [HistoryItem] = []
    
    var sectionCells: [SectionItem] = []
    
    init(scale: HistoryTimeScale) {
        self.timeScale = scale
    }
    
    func updateHistory(elements: [HistoryElement]) {
        cells = elements.map { cellsFactory.make(fromElement: $0, scale: timeScale) }
    }
    

    
    func groupCellsByDate() {
        let orderedSectionIdentifiers = cells
            .map { $0.sectionIdentifier }
            .uniqued()

        sectionCells = orderedSectionIdentifiers
            .map { (identifier) in
                .init(
                    identifier: identifier,
                    cellItems: cells.filter { $0.sectionIdentifier == identifier }
                )
            }
      }
}
