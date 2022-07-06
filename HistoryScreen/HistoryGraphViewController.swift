//
//  StatisticsGraphViewController.swift
//
//  Created by Leonid Vilner on 03.03.2022.
//

import Foundation
import UIKit
import Combine

class HistoryGraphViewController: UIViewController, UICollectionViewDelegate {

    private let dataSource: HistoryDataSource
    private var cancellables: Set<AnyCancellable> = []
    private var historyCollectionView: HistoryCollectionView = .init()
    private var viewModel: HistoryGraphViewModel
    
    init(dataSource: HistoryDataSource, scale: HistoryTimeScale) {
        self.dataSource = dataSource
        self.viewModel = HistoryGraphViewModel(scale: scale)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        historyCollectionView.setContent(viewModel)
        subscribeToHistoryData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        historyCollectionView.scrollCollectionToRight()
    }
    
    private func initialSetup() {
        
        view.backgroundColor = UIColor.clear
        
        view.addSubview(historyCollectionView)
        historyCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func subscribeToHistoryData() {
        dataSource.onAllHistoryUpdates()
            .sink { [weak self] historyElements in
                guard let self = self else { return }
                self.viewModel.updateHistory(elements: historyElements)
                self.viewModel.groupCellsByDate()
                self.historyCollectionView.setContent(self.viewModel)
            }
            .store(in: &cancellables)
    }
}
