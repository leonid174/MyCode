//
//  HistoryCollectionView.swift
//
//  Created by Leonid Vilner on 07.03.2022.
//

import Foundation
import UIKit
import Combine

class HistoryCollectionView: UIView, UICollectionViewDelegate {
    
    private var cancellables: Set<AnyCancellable> = []
    
    typealias CellRegistration = UICollectionView.CellRegistration<HistoryCollectionCell, Date>
    typealias DataSource = UICollectionViewDiffableDataSource<HistoryHeaderItem, Date>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<HistoryHeaderItem, Date>
    
    private var graphViewModel: HistoryGraphViewModel?
    
    private lazy var collectionLayout: UICollectionViewLayout = Self.makeCollectionLayout()
    private lazy var collectionView: UICollectionView = .init(
        frame: .zero,
        collectionViewLayout: collectionLayout
    )

    private lazy var cellRegistration: CellRegistration = .init {
        [weak self] (cell,indexPath,itemIdentifier) in
        guard let viewModel = self?.graphViewModel else { assertionFailure(); return }
        guard let viewItem = viewModel.sectionCells[indexPath.section].cellItems.element(at: indexPath.item) else { return }
        cell.setContent(viewItem)
    }

    private lazy var dataSource: DataSource = .init(
        collectionView: collectionView,
        cellProvider: { [registration = cellRegistration] (collectionView, indexPath, date) in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: date)
        }
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollCollectionToRight()
    }
    
    private func initialSetup() {
        backgroundColor = UIColor.clear
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        
        collectionView.register(HistorySectionSeparatorView.self, forSupplementaryViewOfKind: "separator", withReuseIdentifier: HistorySectionSeparatorView.reuseIdentifier)
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            
            if kind == "separator" {
                guard let separatorView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HistorySectionSeparatorView.reuseIdentifier, for: indexPath) as? HistorySectionSeparatorView else { return HistorySectionSeparatorView() }
                separatorView.dateLabel.text = self?.graphViewModel?.sectionCells[indexPath.section].identifier
                return separatorView
            } else {
                return nil
            }
        }
        
        collectionView.dataSource = dataSource

        collectionView.contentInset = .init(top: 0, left: 0, bottom: 0, right: 24)
    }
}

extension HistoryCollectionView {
    func setContent(_ viewModel: HistoryGraphViewModel) {
        self.graphViewModel = viewModel
        self.collectionLayout = Self.makeCollectionLayout(countOfItems: viewModel.cells.count)
        self.collectionView.setCollectionViewLayout(collectionLayout, animated: false)

        var dataSnapshot: DataSourceSnapshot = .init()
        let sections = viewModel.sectionCells.map({ HistoryHeaderItem.init(title: $0.identifier) })
        
        viewModel.sectionCells
            .map { $0.cellItems.map { $0.date} }
            .enumerated()
            .forEach { dataSnapshot.appendItems($0.element, toSection: sections[$0.offset]) }
        
        dataSource.apply(dataSnapshot, completion: { [weak self] in
            guard let self = self else { return }
            self.collectionView.indexPathsForVisibleItems
                .map { self.collectionView.cellForItem(at: $0) }
                .compactMap { $0 as? HistoryCollectionCell }
                .forEach { cell in
                    let newViewItem = viewModel.cells.first {
                        $0.sectionIdentifier == cell.viewItem?.sectionIdentifier &&
                        $0.date == cell.date
                    }
                    newViewItem.map(cell.setContent)
                }
        })
    }
}

extension HistoryCollectionView {
    static func makeCollectionLayoutCellItem() -> NSCollectionLayoutItem {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute((UIScreen.main.bounds.width - (24.0 * 7.0)) / 6.0),
            heightDimension: .fractionalHeight(1.0/1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.edgeSpacing = .init(
            leading: .fixed(24),
            top: .fixed(0),
            trailing: .fixed(24),
            bottom: .fixed(6)
        )
        return item
    }

    static func makeCollectionLayout(countOfItems: Int = Int.max) -> UICollectionViewLayout {
        let cellItem = Self.makeCollectionLayoutCellItem()

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(50),
            heightDimension: .fractionalHeight(1)
        )
        
        let separatorSize = NSCollectionLayoutSize(
            widthDimension: .absolute(27),
            heightDimension: .fractionalHeight(1)
        )
        
        
        
        let itemsGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [cellItem])

        let section = NSCollectionLayoutSection(group: itemsGroup)
        let maxItemsOnScreen = 6
        let interItemSpacing: CGFloat = 24.0
        
        if countOfItems < maxItemsOnScreen {
            let cellWidth = (UIScreen.main.bounds.width - (interItemSpacing * CGFloat(maxItemsOnScreen + 1))) / CGFloat(maxItemsOnScreen)
            let totalCellWidth = cellWidth * CGFloat(countOfItems)
            let totalSpacingWidth = interItemSpacing * CGFloat(countOfItems + 1)
            let inset = (UIScreen.main.bounds.width - (totalCellWidth + totalSpacingWidth)) / 2
            section.contentInsets = .init(top: 0, leading: inset - 25, bottom: 0, trailing: inset + 25)
        } else {
            section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        }

        let sectionSeparator = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: separatorSize, elementKind: "separator", alignment: .leading)
        section.boundarySupplementaryItems = [sectionSeparator]
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal

        return UICollectionViewCompositionalLayout(section: section, configuration: configuration)
    }
}

extension HistoryCollectionView {
    func scrollCollectionToRight() {
        let numberOfItems = Array(0..<collectionView.numberOfSections)
            .map { collectionView.numberOfItems(inSection: $0) }
            .reduce(0, +)
        if numberOfItems >= 6 {
            let lastSectionIndex = collectionView.numberOfSections - 1
            let lastItemInSection = collectionView.numberOfItems(inSection: lastSectionIndex) - 1
            let lastItemIndex = IndexPath(item: lastItemInSection, section: lastSectionIndex)
            collectionView.scrollToItem(at: lastItemIndex, at: .right, animated: false)
        }
    }
}
