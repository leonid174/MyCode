//
//  HistoryIndicatorCell.swift
//  Altos-app
//
//  Created by Leonid Vilner on 23.02.2022.
//

import Foundation
import UIKit
import SnapKit

class HistoryCollectionCell: UICollectionViewCell {
    
    var viewItem: HistoryItem?
    var date: Date?
    
    private var emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .light
                ? UIColor(hexString: "#F3F3F3")
                : UIColor.white.withAlphaComponent(0.09)
        }
        return view
    }()
    
    private var gradientView: UIView = {
        let view = UIView()
        return view
    }()
    
    private var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.locations = [0.0,0.5]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.name = "Gradient"
        layer.isHidden = false
        return layer
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = R.color.primaryDark()!
        label.backgroundColor = R.color.primaryBackground()!
        label.font = R.font.ttHovesRegular(size: 13)
        return label
    }()
    
    private let bluetoothOffImage: UIImageView = {
        let image = UIImageView()
        image.image = R.image.bluetooth_off()!
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = R.color.primaryDark()!
        label.font = R.font.ttHovesRegular(size: 10)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        valueLabel.layer.cornerRadius = valueLabel.frame.width/2
        valueLabel.clipsToBounds = true
        
        emptyView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height - 70)
        gradientLayer.frame = gradientView.bounds
        gradientLayer.removeAllAnimations()
        gradientView.layer.cornerRadius = gradientView.frame.width/2
        gradientView.clipsToBounds = true
    }

    private func initialSetup() {
        addSubview(emptyView)
        emptyView.layer.cornerRadius = frame.width / 2
        emptyView.clipsToBounds = true
        
        emptyView.addSubview(bluetoothOffImage)
        bluetoothOffImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(15)
        }
        
        addSubview(gradientView)
        gradientView.backgroundColor = UIColor.init(hexString: "#F3F3F3").withAlphaComponent(0.7)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)

        valueLabel.frame = CGRect(x: 2, y: 2, width: frame.width - 4, height: frame.width - 4)
        gradientView.addSubview(valueLabel)
        
        addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-24)
        }
    }

    private func updateGradientConstraints(viewItem: HistoryItem) {
        let cellHeight = CGFloat(frame.height - 66)
        let gradientHeight: CGFloat
        if viewItem.value != 1 {
            gradientHeight = cellHeight * (CGFloat(viewItem.value) / CGFloat(viewItem.maxValue))
        } else {
            gradientHeight = frame.width
        }
        gradientView.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(gradientHeight)
            make.bottom.equalToSuperview().offset(-66)
        }
    }
}

extension HistoryCollectionCell {
    func setContent(_ viewItem: HistoryItem) {
        if self.viewItem == viewItem { return }

        self.viewItem = viewItem
        date = viewItem.date
        dateLabel.text = viewItem.dateFormatter.string(from: viewItem.date)
        
        setGradient(viewItem: viewItem)
        setValueLabel(viewItem: viewItem)

        bluetoothOffImage.isHidden = viewItem.value > 0
    }
    
    private func setGradient(viewItem: HistoryItem) {
        updateGradientConstraints(viewItem: viewItem)
        switch viewItem.value {
        case 1...3:
            gradientLayer.colors = [
                UIColor.init(hexString: "F6C3AD").cgColor,
                UIColor.init(hexString: "FF957D").cgColor
            ]
        case 4...6:
            gradientLayer.colors = [
                UIColor.init(hexString: "A0E179").cgColor,
                UIColor.init(hexString: "9FCD83").cgColor
            ]
        case 7...10:
            gradientLayer.colors = [
                UIColor.init(hexString: "8EEFE9").cgColor,
                UIColor.init(hexString: "B4F4F0").cgColor
            ]
        default:
            gradientLayer.colors = [
                UIColor.clear.cgColor,
                UIColor.clear.cgColor
            ]
        }
    }

    private func setValueLabel(viewItem: HistoryItem) {
        valueLabel.text = String(viewItem.value)
        bringSubviewToFront(valueLabel)
    }
}
