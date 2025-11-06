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
        static let navigationTitle = R.string.localizable.trackers()
        static let regularTracker = R.string.localizable.regular_tracker()
        static let irregularTracker = R.string.localizable.irregular_tracker()
        
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
    private var trackerToEdit: Tracker?
    private var editingCategory: String = ""
    
    // MARK: - Initializer
    init(trackerToEdit: Tracker? = nil, delegate: TrackerViewControllerDelegate?) {
        self.trackerToEdit = trackerToEdit
        self.editingCategory = trackerToEdit?.category ?? ""
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        if let tracker = trackerToEdit {
            setupForEditing(tracker)
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .ypWhite
        setupViews()
        setupConstraints()
    }
    
    private func setupForEditing(_ tracker: Tracker) {
        title = R.string.localizable.editing()
        // Заполняем данные трекера для редактирования
        // В зависимости от типа трекера (привычка или событие)
        // переходим в соответствующий контроллер конфигурации
        if tracker.scheduleTrackers.isEmpty {
            // Нерегулярное событие
            let eventVC = EventConfigurationViewController(
                trackerToEdit: tracker,
                delegate: delegate
            )
            navigationController?.pushViewController(eventVC, animated: false)
        } else {
            // Привычка
            let habitVC = HabitConfigurationViewController(
                trackerToEdit: tracker,
                delegate: delegate
            )
            navigationController?.pushViewController(habitVC, animated: false)
        }
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
        // Аналитика: выбор привычки
        AnalyticsService.shared.report(event: "click", params: [
            "screen": "TrackerType",
            "item": "habit"
        ])
        navigateToTrackerCreation(isRegular: true)
    }
    
    private func irregularTrackerButtonTapped() {
        // Аналитика: выбор события
        AnalyticsService.shared.report(event: "click", params: [
            "screen": "TrackerType",
            "item": "event"
        ])
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
