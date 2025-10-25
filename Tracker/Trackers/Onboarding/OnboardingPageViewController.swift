//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 19.10.2025.
//

import UIKit

// MARK: - Onboarding Page View Controller
final class OnboardingPageViewController: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let horizontalInset: CGFloat = 20
        static let horizontalPadding: CGFloat = 16
        static let bottomOffset: CGFloat = 270
        static let bottomButtonOffset: CGFloat = 50
        static let buttonHeight: CGFloat = 60
        static let buttonCornerRadius: CGFloat = 16
        static let titleFontSize: CGFloat = 32
        static let buttonFontSize: CGFloat = 16
    }
    
    // MARK: - UI Components
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: page.imageName)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .bold)
        label.text = page.titleText
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        let buttonTitle = NSLocalizedString(
            "cool_technologies",
            comment: "Action button title on onboarding screen"
        )
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addAction(UIAction { [weak self] _ in
            self?.didTapActionButton()
        }, for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Properties
    private let page: OnboardingPage
    
    // MARK: - Initializer
    init(page: OnboardingPage) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .ypWhite
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        view.addSubview(actionButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background Image
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Title Label
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                constant: Constants.horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                 constant: -Constants.horizontalPadding),
            titleLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                               constant: -Constants.bottomOffset),
            
            // Action Button
            actionButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                  constant: Constants.horizontalInset),
            actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                   constant: -Constants.horizontalInset),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                 constant: -Constants.bottomButtonOffset),
            actionButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
    
    // MARK: - Actions
    private func didTapActionButton() {
        // Сохраняем факт прохождения онбординга
        OnboardingStorage.isOnboardingCompleted = true
        
        // Переключаемся на главный экран
        switchToMainApp()
    }
    
    private func switchToMainApp() {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: {
            $0.activationState == .foregroundActive
        }) as? UIWindowScene,
              let window = windowScene.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
    }
}
