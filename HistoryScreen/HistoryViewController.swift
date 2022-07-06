//
//  HistoryViewController.swift
//
//  Created by Leonid Vilner on 21.02.2022.
//

import UIKit
import Combine

class HistoryViewController: UIViewController {

    private lazy var dataSource: HistoryDataSource = makeDataSource(forScale: .hours)
    private var viewModel: HistoryViewModel = .init(scale: .hours)

    private let stateBannerView: StateBannerView = .init()
    private weak var historyGraphViewController: HistoryGraphViewController?
    
    var transitionInteractor: SideTransitionInteractor? = nil

    private var historyTimeScaleCancellable: AnyCancellable?
    private var historyContentCancellables = Set<AnyCancellable>()

    var onTimeScaleUpdates: PassthroughSubject<HistoryTimeScale, Never> = .init()

    private var cancellables = Set<AnyCancellable>()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 25
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.ttHovesRegular(size: 25)!
        label.textColor = R.color.primaryDark()!
        label.text = "Statistic"
        return label
    }()
    
    private let rightArrow: UIButton = {
        let button = UIButton()
        button.setImage(R.image.right_arrow()!, for: .normal)
        button.tintColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .light
                ? UIColor(hexString: "#2C2C2C").withAlphaComponent(0.6)
                : UIColor(hexString: "#A6A6A6")
        }
        button.addTarget(self, action: #selector(dismissHistory), for: .touchUpInside)
        return button
    }()
    
    private let topStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 25
        return stack
    }()
    
    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    init(timeScale: HistoryTimeScale) {
        self.viewModel = .init(scale: timeScale)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        initialSetup()
        addSwipeRecognizer()
        transitioningDelegate = self
        setupToggleDateButtons()
        subscribeToTimeScaleUpdates()
    }

    private func addSwipeRecognizer() {
        let swipeLeft = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgePanGesture))
        swipeLeft.edges = .right
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    @objc private func dismissHistory() {
        
        self.dismiss(animated: true)
    }

    private func setHistoryGraphViewController(forScale timeScale: HistoryTimeScale, _ dataSource: HistoryDataSource) {
        if let existViewController = self.historyGraphViewController {
            existViewController.willMove(toParent: nil)
            stackView.arrangedSubviews.last?.removeFromSuperview()
            existViewController.removeFromParent()
            existViewController.didMove(toParent: nil)
            self.historyGraphViewController = nil
        }
        let newViewController = HistoryGraphViewController(dataSource: dataSource, scale: timeScale)
        newViewController.willMove(toParent: self)
        addChild(newViewController)
        stackView.addArrangedSubview(newViewController.view)
        newViewController.didMove(toParent: self)
        self.historyGraphViewController = newViewController
    }

    private func makeDataSource(forScale timeScale: HistoryTimeScale) -> HistoryDataSource {
        switch timeScale {
            case .days: return HistoryDaysAltosDataSource()
            case .hours: return HistoryHoursAltosDataSource()
            case .months: return HistoryMonthsAltosDataSource()
        }
    }

    private func updateContent(forScale timeScale: HistoryTimeScale) {
        let dataSource = makeDataSource(forScale: timeScale)
        setHistoryGraphViewController(forScale: timeScale, dataSource)
        viewModel.timeScale = timeScale

        dataSource.readAverage(forCursor: .init(date: Date()))
            .sink { [weak self] in
                guard let self = self else { return }
                self.stateBannerView.setBannerValue(value: $0, viewModel: self.viewModel)
            }
            .store(in: &cancellables)
    }
    
    private func initialSetup() {
        
        view.backgroundColor = R.color.primaryBackground()!
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(57)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(rightArrow)
        rightArrow.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.right.equalToSuperview().inset(17)
        }
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(25)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        stackView.addArrangedSubview(topStackView)
        topStackView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        topStackView.addArrangedSubview(stateBannerView)
        stateBannerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        topStackView.addArrangedSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.width.equalToSuperview().multipliedBy(0.4)
        }
        
        let initialTimeScale: HistoryTimeScale = .days
        updateContent(forScale: initialTimeScale)
    }
    
    private func updateStatusBannerText() {
        stateBannerView.titleLabel.text = viewModel.stateBannerText()
    }

    private func subscribeToTimeScaleUpdates() {
        historyTimeScaleCancellable?.cancel()
        historyTimeScaleCancellable = onTimeScaleUpdates
            .sink { [weak self] in
                self?.updateContent(forScale: $0)
            }
    }
    
    @objc private func dateButtonAction(_ sender: UIButton) {
        let senderScale = viewModel.possibleScales.first { $0.toToggleButtonTag() == sender.tag } ?? viewModel.timeScale
        viewModel.timeScale = senderScale
        updateStatusBannerText()
        updateToggleDateButtonsSelection()
        onTimeScaleUpdates.send(senderScale)
    }
}

private extension HistoryViewController {
    func setupToggleDateButtons() {
        viewModel.possibleScales.forEach { scale in
            let button = UIButton()
            button.tag = scale.toToggleButtonTag()
            button.setTitle(scale.toToggleButtonText(), for: .normal)
            button.titleLabel?.font = R.font.ttHovesRegular(size: 18)!
            button.setTitleColor(R.color.primaryText()!, for: .normal)
            button.frame.size = CGSize(width: 42, height: 25)
            button.layer.cornerRadius = button.frame.height/2
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(dateButtonAction(_:)), for: .touchUpInside)
            buttonStackView.addArrangedSubview(button)
        }
        updateToggleDateButtonsSelection()
    }

    func updateToggleDateButtonsSelection() {
        let allScales = viewModel.possibleScales
        let selectedScale = viewModel.timeScale

        buttonStackView.arrangedSubviews.forEach { toggleButton in
            let buttonScale = allScales.first { $0.toToggleButtonTag() == toggleButton.tag }

            let selectedBackgroundColor = UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .light
                    ? UIColor(hexString: "#F3F3F3")
                    : UIColor(hexString: "#171717")
            }
            let selectedTextColor = UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .light
                    ? UIColor(hexString: "#27282F")
                    : UIColor(hexString: "#FFFFFF")
            }
            let textColor = UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .light
                    ? UIColor(hexString: "#818395")
                    : UIColor(hexString: "#ADADAD")
            }
            toggleButton.backgroundColor = buttonScale == selectedScale
                ? selectedBackgroundColor
                : UIColor.clear
            (toggleButton as? UIButton)?.setTitleColor(buttonScale == selectedScale ? selectedTextColor : textColor, for: .normal)
        }
    }
}

extension HistoryViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SideInteractiveTransition(action: .dismiss)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return transitionInteractor?.hasStarted ?? false ? transitionInteractor : nil
    }
}

private extension HistoryTimeScale {
    func toToggleButtonText() -> String {
        switch self {
            case .months: return "M"
            case .days: return "D"
            case .hours: return "H"
        }
    }

    func toToggleButtonTag() -> Int {
        toToggleButtonText().hashValue
    }
}

extension HistoryViewController: UIGestureRecognizerDelegate {
    @objc func edgePanGesture(gesture: UIScreenEdgePanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let progress = SideInteractiveTransition.calculateProgress(
            translationInView: translation,
            viewBounds: view.bounds,
            direction: .left
        )
        SideInteractiveTransition.mapGestureStateToInteractor(
            gesture: gesture,
            progress: progress,
            transitionInteractor: transitionInteractor,
            transitionTrigger: dismissHistory
        )
    }
}
