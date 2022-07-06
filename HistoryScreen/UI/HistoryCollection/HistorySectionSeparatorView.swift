//
//  SupplementaryView.swift
//  Altos-app
//
//  Created by Leonid Vilner on 23.05.2022.
//

import Foundation
import UIKit

class HistorySectionSeparatorView: UICollectionReusableView {
    
    static var reuseIdentifier: String {
        return String(describing: HistorySectionSeparatorView.self)
    }
    
    private var emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .light
            ? UIColor.black.withAlphaComponent(0.03)
                : UIColor.white.withAlphaComponent(0.3)
        }
        return view
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = R.color.primaryDark()!
        label.font = R.font.ttHovesRegular(size: 10)
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        emptyView.frame = CGRect(x: frame.width - 4, y: 0, width: 4, height: frame.height - 70)
    }
    
    private func initialSetup() {
     
        addSubview(emptyView)
        emptyView.layer.cornerRadius = 2
        emptyView.clipsToBounds = true
        
        addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-24)
        }
    }
}
