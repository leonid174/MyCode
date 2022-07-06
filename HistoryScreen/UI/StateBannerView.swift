//
//  StateBannerView.swift
//  Altos-app
//
//  Created by Leonid Vilner on 21.02.2022.
//

import UIKit

class StateBannerView: UIView {
    
    private let mainLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.ttHovesLight(size: 56)!
        label.textColor = R.color.primaryText()!
        return label
    }()
    
    private let secondaryLabel: UILabel = {
        let label = UILabel()
        label.text = "/10"
        label.font = R.font.ttHovesRegular(size: 16)!
        label.textColor = R.color.secondaryText()!
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "Your air for in a month"
        label.font = R.font.ttHovesDemiBold(size: 16)!
        label.textColor = R.color.primaryText()!
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Means that you are mostly in a productive atmosphere."
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = R.font.ttHovesRegular(size: 16)!
        label.textColor = R.color.primaryText()!
        return label
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.locations = [0.0, 1.0]
        return layer
    }()
    
    private let infoImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.image = R.image.info_ellipse()!
        return image
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
        gradientLayer.frame = bounds
    }
    
    private func initialSetup() {

        overrideUserInterfaceStyle = .light
        layer.cornerRadius = 10
        clipsToBounds = true
        backgroundColor = UIColor.init(hexString: "#E9FAFB")
        layer.addSublayer(gradientLayer)
        
        addSubview(mainLabel)
        mainLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(22)
            make.height.equalTo(52)
        }
        
        addSubview(secondaryLabel)
        secondaryLabel.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.top).offset(4)
            make.left.equalTo(mainLabel.snp.right).offset(2)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.right.equalToSuperview().inset(44)
            make.left.equalToSuperview().inset(122)
        }
        
        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.right.equalToSuperview().inset(44)
            make.left.equalToSuperview().inset(122)
            make.bottom.equalToSuperview().inset(24)
        }
        
        addSubview(infoImage)
        infoImage.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
        }

        mainLabel.textColor = R.color.primaryText(compatibleWith: traitCollection)!
        secondaryLabel.textColor = R.color.secondaryText(compatibleWith: traitCollection)!
        titleLabel.textColor = R.color.primaryText(compatibleWith: traitCollection)!
        descriptionLabel.textColor = R.color.primaryText(compatibleWith: traitCollection)!
    }
}

extension StateBannerView {
    func setBannerValue(value: Int, viewModel: HistoryViewModel) {
        mainLabel.text = String(value)
        switch value {
        case Int.min...3:
            gradientLayer.colors = viewModel.stateBannerColors(state: .low)
        case 4...6:
            gradientLayer.colors = viewModel.stateBannerColors(state: .balanced)
        default:
            gradientLayer.colors = viewModel.stateBannerColors(state: .high)
        }
        descriptionLabel.text = BrainFuelTextProvider.getPrompt(brainFuelValue: value, stateConnect: true)
    }
}
