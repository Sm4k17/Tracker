//
//  CreationTrackerViewController.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 30.09.2025.
//

import UIKit

// MARK: - Tracker Creation View Controller
final class CreationTrackerViewController: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let navigationTitle = "Создание трекера"
        static let regularTracker = "Привычка"
        static let irregularTracker = "Нерегулярное событие"
        
        // Константы для размеров и отступов
        enum Layout {
            static let buttonHeight: CGFloat = 60
            static let buttonCornerRadius: CGFloat = 16
            static let stackSpacing: CGFloat = 16
            static let horizontalInset: CGFloat = 20
        }
        
        // Шрифты
        enum Fonts {
            static let buttonFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        }
        
        // Цвета
        enum Colors {
            static let buttonBackground: UIColor = .ypBlack
            static let buttonText: UIColor = .ypWhite
        }
    }
    
    // MARK: - UI Components
    private lazy var regularTrackerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.regularTracker, for: .normal)
        button.titleLabel?.font = Constants.Fonts.buttonFont
        button.backgroundColor = Constants.Colors.buttonBackground
        button.setTitleColor(Constants.Colors.buttonText, for: .normal)
        button.layer.cornerRadius = Constants.Layout.buttonCornerRadius
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addAction(UIAction { [weak self] _ in
            self?.regularTrackerButtonTapped()
        }, for: .touchUpInside)
        
        return button
    }()
    
    private lazy var irregularTrackerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.irregularTracker, for: .normal)
        button.titleLabel?.font = Constants.Fonts.buttonFont
        button.backgroundColor = Constants.Colors.buttonBackground
        button.setTitleColor(Constants.Colors.buttonText, for: .normal)
        button.layer.cornerRadius = Constants.Layout.buttonCornerRadius
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addAction(UIAction { [weak self] _ in
            self?.irregularTrackerButtonTapped()
        }, for: .touchUpInside)
        
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.Layout.stackSpacing
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Properties
    private weak var delegate: TrackerViewControllerDelegate?
    
    // MARK: - Initializer
    init(delegate: TrackerViewControllerDelegate?) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .ypWhite
        setupViews()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        title = Constants.navigationTitle
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = nil
    }
    
    private func setupViews() {
        buttonStackView.addArrangedSubview(regularTrackerButton)
        buttonStackView.addArrangedSubview(irregularTrackerButton)
        
        view.addSubview(buttonStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Stack View Constraints
            buttonStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.Layout.horizontalInset
            ),
            buttonStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Constants.Layout.horizontalInset
            ),
            buttonStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Button Height Constraints
            regularTrackerButton.heightAnchor.constraint(
                equalToConstant: Constants.Layout.buttonHeight
            ),
            irregularTrackerButton.heightAnchor.constraint(
                equalToConstant: Constants.Layout.buttonHeight
            )
        ])
    }
    
    // MARK: - Actions
    private func regularTrackerButtonTapped() {
        navigateToTrackerCreation(isRegular: true)
    }
    
    private func irregularTrackerButtonTapped() {
        navigateToTrackerCreation(isRegular: false)
    }
    
    private func navigateToTrackerCreation(isRegular: Bool) {
        guard let delegate = delegate else { return }
        
        if isRegular {
            // Для привычек
            let habitVC = HabitConfigurationViewController(delegate: delegate)
            navigationController?.pushViewController(habitVC, animated: true)
        } else {
            // Для нерегулярных событий
            let eventVC = EventConfigurationViewController(delegate: delegate)
            navigationController?.pushViewController(eventVC, animated: true)
        }
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview("Creation Tracker View") {
    let viewController = CreationTrackerViewController(delegate: nil)
    let navigationController = UINavigationController(rootViewController: viewController)
    return navigationController
}
#endif
