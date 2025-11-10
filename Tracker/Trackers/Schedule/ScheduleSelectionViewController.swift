//
//  ScheduleSelectionViewController.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 30.09.2025.
//

import UIKit

// MARK: - Schedule Selection View Controller
final class ScheduleSelectionViewController: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let navigationTitle = R.string.localizable.schedule()
        static let readyButtonTitle = R.string.localizable.ready()
        
        enum Layout {
            static let horizontalInset: CGFloat = 16
            static let buttonHeight: CGFloat = 60
            static let cornerRadius: CGFloat = 16
            static let stackViewTopInset: CGFloat = 24
            static let buttonBottomInset: CGFloat = 16
            static let rowHeight: CGFloat = 75
            static let separatorHeight: CGFloat = 0.5
        }
        
        enum Fonts {
            static let button: UIFont = .systemFont(ofSize: 16, weight: .medium)
            static let dayLabel: UIFont = .systemFont(ofSize: 17, weight: .regular)
        }
        
        enum Colors {
            static let buttonText: UIColor = .ypWhite
            static let stackViewBackground: UIColor = .ypBackground
            static let dayLabel: UIColor = .ypBlack
            static let separator: UIColor = .ypGray
            static let switchTint: UIColor = .ypBlue
        }
    }
    
    // MARK: - UI Components
    private lazy var daysStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.backgroundColor = Constants.Colors.stackViewBackground
        stackView.layer.cornerRadius = Constants.Layout.cornerRadius
        stackView.layer.masksToBounds = true
        return stackView
    }()
    
    private lazy var readyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.readyButtonTitle, for: .normal)
        button.titleLabel?.font = Constants.Fonts.button
        button.backgroundColor = .ypBlack
        button.setTitleColor(Constants.Colors.buttonText, for: .normal)
        button.layer.cornerRadius = Constants.Layout.cornerRadius
        button.layer.masksToBounds = true
        button.heightAnchor.constraint(equalToConstant: Constants.Layout.buttonHeight).isActive = true
        
        button.addAction(UIAction { [weak self] _ in
            self?.didTapReadyButton()
        }, for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Properties
    private let selectedDays: Set<Week>
    private let onScheduleSelected: (Set<Week>) -> Void
    private var currentSelectedDays: Set<Week>
    
    // MARK: - Initializer
    init(selectedDays: Set<Week>, onScheduleSelected: @escaping (Set<Week>) -> Void) {
        self.selectedDays = selectedDays
        self.currentSelectedDays = selectedDays
        self.onScheduleSelected = onScheduleSelected
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDays()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .ypWhite
        setupNavigationBar()
        setupViews()
        setupConstraints()
        setupAutoresizingMasks()
    }
    
    private func setupNavigationBar() {
        title = Constants.navigationTitle
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = nil
    }
    
    private func setupViews() {
        view.addSubview(daysStackView)
        view.addSubview(readyButton)
    }
    
    private func setupAutoresizingMasks() {
        [daysStackView, readyButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            daysStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Layout.stackViewTopInset),
            daysStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.horizontalInset),
            daysStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.horizontalInset),
            daysStackView.bottomAnchor.constraint(equalTo: readyButton.topAnchor, constant: -39),
            
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.horizontalInset),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.horizontalInset),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Layout.buttonBottomInset)
        ])
    }
    
    // MARK: - Days Setup
    private func setupDays() {
        let days = Week.allCases
        
        for (index, day) in days.enumerated() {
            let dayLabel = createDayLabel(for: day)
            let switchControl = createSwitch(for: day)
            
            let horizontalStack = UIStackView(arrangedSubviews: [dayLabel, switchControl])
            horizontalStack.axis = .horizontal
            horizontalStack.distribution = .equalSpacing
            horizontalStack.alignment = .center
            horizontalStack.isLayoutMarginsRelativeArrangement = true
            horizontalStack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            
            let containerStack = UIStackView()
            containerStack.axis = .vertical
            containerStack.addArrangedSubview(horizontalStack)
            
            if index < days.count - 1 {
                insertSeparatorLine(to: containerStack)
            }
            
            daysStackView.addArrangedSubview(containerStack)
        }
    }
    
    private func createDayLabel(for day: Week) -> UILabel {
        let label = UILabel()
        label.text = day.localizedTitle
        label.font = Constants.Fonts.dayLabel
        label.textColor = Constants.Colors.dayLabel
        return label
    }
    
    private func createSwitch(for day: Week) -> UISwitch {
        let switchControl = UISwitch()
        switchControl.onTintColor = Constants.Colors.switchTint
        switchControl.isOn = currentSelectedDays.contains(day)
        
        switchControl.addAction(UIAction { [weak self] _ in
            if switchControl.isOn {
                self?.currentSelectedDays.insert(day)
            } else {
                self?.currentSelectedDays.remove(day)
            }
        }, for: .valueChanged)
        
        return switchControl
    }
    
    private func insertSeparatorLine(to stackView: UIStackView) {
        let separator = UIView()
        separator.backgroundColor = Constants.Colors.separator
        
        let separatorContainer = UIView()
        separatorContainer.addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: separatorContainer.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: separatorContainer.trailingAnchor, constant: -16),
            separator.topAnchor.constraint(equalTo: separatorContainer.topAnchor),
            separator.bottomAnchor.constraint(equalTo: separatorContainer.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: Constants.Layout.separatorHeight)
        ])
        
        stackView.addArrangedSubview(separatorContainer)
    }
    
    // MARK: - Actions
    private func didTapReadyButton() {
        onScheduleSelected(currentSelectedDays)
        navigationController?.popViewController(animated: true)
    }
}
