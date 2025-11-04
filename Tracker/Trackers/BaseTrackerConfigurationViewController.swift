//
//  BaseTrackerConfigurationViewController.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 03.11.2025.
//

import UIKit

// MARK: - Base Tracker Configuration View Controller
class BaseTrackerConfigurationViewController: UIViewController {
    
    // MARK: - Constants
    enum Constants {
        static let namePlaceholder = R.string.localizable.enter_tracker_name()
        static let categoryTitle = R.string.localizable.category()
        static let categorySubtitle = ""
        static let emojiTitle = R.string.localizable.emoji()
        static let colorTitle = R.string.localizable.color()
        static let symbolsLimitMessage = R.string.localizable.symbols_limit()
        static let symbolsLimit = 38
        
        // Константы для размеров и отступов
        enum Layout {
            static let horizontalInset: CGFloat = 16
            static let buttonHeight: CGFloat = 60
            static let cornerRadius: CGFloat = 16
            static let textFieldHeight: CGFloat = 75
            static let dropdownItemHeight: CGFloat = 75
            static let symbolsLimitLabelHeight: CGFloat = 22
            
            // Используем унифицированные высоты коллекций
            static var emojiCollectionHeight: CGFloat {
                return EmojiSelectionView.Layout.calculateCollectionHeight(
                    itemCount: EmojiSelectionView.Constants.emojis.count
                )
            }
            
            static var colorCollectionHeight: CGFloat {
                return ColorSelectionView.Layout.calculateCollectionHeight(
                    itemCount: ColorSelectionView.Constants.colors.count
                )
            }
        }
        
        // Шрифты
        enum Fonts {
            static let sectionTitle: UIFont = .systemFont(ofSize: 19, weight: .bold)
            static let button: UIFont = .systemFont(ofSize: 16, weight: .medium)
            static let dropdownTitle: UIFont = .systemFont(ofSize: 16, weight: .regular)
            static let dropdownSubtitle: UIFont = .systemFont(ofSize: 16, weight: .regular)
        }
        
        // Цвета
        enum Colors {
            static let sectionTitle: UIColor = .ypBlack
            static let buttonText: UIColor = .ypWhite
            static let cancelButtonText: UIColor = .ypRed
            static let dropdownTitle: UIColor = .ypBlack
            static let dropdownSubtitle: UIColor = .ypGray
            static let dropdownBackground: UIColor = .ypBackground
        }
    }
    
    // MARK: - UI Components
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 24, left: Constants.Layout.horizontalInset,
                                           bottom: 24, right: Constants.Layout.horizontalInset)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.namePlaceholder
        textField.backgroundColor = .ypBackground
        textField.layer.cornerRadius = Constants.Layout.cornerRadius
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.heightAnchor.constraint(equalToConstant: Constants.Layout.textFieldHeight).isActive = true
        
        textField.addAction(UIAction { [weak self] _ in
            self?.updateCreateButtonState()
        }, for: .editingChanged)
        
        return textField
    }()
    
    lazy var symbolsLimitLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRed
        label.text = Constants.symbolsLimitMessage
        label.textAlignment = .center
        label.isHidden = true
        label.alpha = 0
        label.heightAnchor.constraint(equalToConstant: Constants.Layout.symbolsLimitLabelHeight).isActive = true
        return label
    }()
    
    lazy var categoryContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.backgroundColor = Constants.Colors.dropdownBackground
        stack.layer.cornerRadius = Constants.Layout.cornerRadius
        stack.layer.masksToBounds = true
        return stack
    }()
    
    lazy var categoryButton: UIButton = {
        createDropdownButton(
            title: Constants.categoryTitle,
            subtitle: Constants.categorySubtitle
        ) { [weak self] in
            self?.didTapCategoryButton()
        }
    }()
    
    lazy var emojiSelectionView: EmojiSelectionView = {
        let view = EmojiSelectionView()
        view.delegate = self
        return view
    }()
    
    lazy var colorSelectionView: ColorSelectionView = {
        let view = ColorSelectionView()
        view.delegate = self
        return view
    }()
    
    lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var cancelButton: UIButton = {
        createActionButton(
            title: cancelButtonTitle,
            backgroundColor: .clear,
            titleColor: Constants.Colors.cancelButtonText,
            borderColor: .ypRed
        ) { [weak self] in
            self?.didTapCancelButton()
        }
    }()
    
    lazy var createButton: UIButton = {
        createActionButton(
            title: createButtonTitle,
            backgroundColor: .ypGray,
            titleColor: Constants.Colors.buttonText
        ) { [weak self] in
            self?.didTapCreateButton()
        }
    }()
    
    lazy var emojiLabel: UILabel = {
        createSectionLabel(text: Constants.emojiTitle)
    }()
    
    lazy var colorLabel: UILabel = {
        createSectionLabel(text: Constants.colorTitle)
    }()
    
    // MARK: - Properties
    weak var delegate: TrackerViewControllerDelegate?
    var trackerToEdit: Tracker?
    var selectedCategory: String = ""
    var selectedEmoji: String = ""
    var selectedColor: UIColor = .systemRed
    var showWarningAnimationStarted = false
    var hideWarningAnimationStarted = false
    
    // MARK: - Abstract Properties (должны быть переопределены в подклассах)
    var navigationTitle: String { "" }
    var cancelButtonTitle: String { R.string.localizable.cancel() }
    var createButtonTitle: String { R.string.localizable.create() }
    
    // MARK: - Initializer
    init(trackerToEdit: Tracker? = nil, delegate: TrackerViewControllerDelegate?) {
        self.trackerToEdit = trackerToEdit
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        
        if let tracker = trackerToEdit {
            setupEditingData(tracker)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupTapGesture()
        updateCreateButtonState()
    }
    
    // MARK: - Setup
    func setupUI() {
        view.backgroundColor = .ypWhite
        setupViews()
        setupConstraints()
    }
    
    func setupNavigationBar() {
        title = navigationTitle
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = nil
    }
    
    func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        setupContentStack()
        
        emojiSelectionView.heightAnchor.constraint(equalToConstant: Constants.Layout.emojiCollectionHeight).isActive = true
        colorSelectionView.heightAnchor.constraint(equalToConstant: Constants.Layout.colorCollectionHeight).isActive = true
        
        view.addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
    }
    
    func setupContentStack() {
        // Базовые элементы, могут быть переопределены
        [nameTextField, symbolsLimitLabel, categoryContainer, emojiLabel,
         emojiSelectionView, colorLabel, colorSelectionView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        updateSpacing()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -16),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.horizontalInset),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.horizontalInset),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: Constants.Layout.buttonHeight)
        ])
    }
    
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Editing Support
    func setupEditingData(_ tracker: Tracker) {
        selectedCategory = tracker.category
        selectedEmoji = tracker.emoji
        selectedColor = tracker.color
        
        updateCategoryButtonSubtitle(tracker.category)
        nameTextField.text = tracker.name
        
        emojiSelectionView.selectEmoji(tracker.emoji)
        colorSelectionView.selectColor(tracker.color)
        
        updateCreateButtonState()
    }
    
    // MARK: - Factory Methods
    func createSectionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = Constants.Fonts.sectionTitle
        label.textColor = Constants.Colors.sectionTitle
        return label
    }
    
    func createDropdownButton(title: String, subtitle: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.contentHorizontalAlignment = .left
        button.layer.masksToBounds = true
        
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = .leading
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Constants.Fonts.dropdownTitle
        titleLabel.textColor = Constants.Colors.dropdownTitle
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = Constants.Fonts.dropdownSubtitle
        subtitleLabel.textColor = Constants.Colors.dropdownSubtitle
        
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(subtitleLabel)
        
        button.addSubview(textStack)
        
        let arrowImageView = UIImageView()
        arrowImageView.image = R.image.chevron()
        arrowImageView.tintColor = .ypGray
        button.addSubview(arrowImageView)
        
        textStack.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textStack.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            textStack.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -8),
            
            arrowImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            arrowImageView.widthAnchor.constraint(equalToConstant: 12),
            arrowImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        
        return button
    }
    
    func createActionButton(
        title: String,
        backgroundColor: UIColor,
        titleColor: UIColor,
        borderColor: UIColor? = nil,
        action: @escaping () -> Void
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = Constants.Fonts.button
        button.backgroundColor = backgroundColor
        button.setTitleColor(titleColor, for: .normal)
        button.layer.cornerRadius = Constants.Layout.cornerRadius
        button.layer.masksToBounds = true
        
        if let borderColor = borderColor {
            button.layer.borderWidth = 1
            button.layer.borderColor = borderColor.cgColor
        }
        
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        
        return button
    }
    
    // MARK: - Helper Methods
    func updateCategoryButtonSubtitle(_ subtitle: String) {
        if let textStack = categoryButton.subviews.first(where: { $0 is UIStackView }) as? UIStackView,
           let subtitleLabel = textStack.arrangedSubviews.last as? UILabel {
            subtitleLabel.text = subtitle
            subtitleLabel.textColor = Constants.Colors.dropdownSubtitle
        }
    }
    
    func updateSpacing() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if self.symbolsLimitLabel.isHidden {
                self.contentStackView.setCustomSpacing(24, after: self.nameTextField)
            } else {
                self.contentStackView.setCustomSpacing(8, after: self.nameTextField)
                self.contentStackView.setCustomSpacing(24, after: self.symbolsLimitLabel)
            }
        }
    }
    
    // MARK: - Symbols Limit Methods
    func checkSymbolsLimit() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let symbolsCount = self.nameTextField.text?.count ?? 0
            symbolsCount > Constants.symbolsLimit ? self.showSymbolsLimitLabel() : self.hideSymbolsLimitLabel()
        }
    }
    
    func showSymbolsLimitLabel() {
        guard !showWarningAnimationStarted && symbolsLimitLabel.isHidden && !hideWarningAnimationStarted else { return }
        showWarningAnimationStarted = true
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            self.symbolsLimitLabel.transform = CGAffineTransform(translationX: 0, y: -10)
            self.symbolsLimitLabel.isHidden = false
            
            self.updateSpacing()
            
            UIView.animate(withDuration: 0.3, animations: {
                self.symbolsLimitLabel.transform = .identity
                self.symbolsLimitLabel.alpha = 1
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.showWarningAnimationStarted = false
            })
        }
    }
    
    func hideSymbolsLimitLabel() {
        guard !hideWarningAnimationStarted && !symbolsLimitLabel.isHidden && !showWarningAnimationStarted else { return }
        hideWarningAnimationStarted = true
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            UIView.animate(withDuration: 0.5, animations: {
                self.symbolsLimitLabel.alpha = 0
                self.symbolsLimitLabel.transform = CGAffineTransform(translationX: 0, y: -10)
                self.view.layoutIfNeeded()
            }) { _ in
                self.symbolsLimitLabel.isHidden = true
                self.symbolsLimitLabel.transform = .identity
                
                self.updateSpacing()
                
                self.hideWarningAnimationStarted = false
            }
        }
    }
    
    func showError(message: String) {
        AnalyticsService.shared.report(event: "error_occurred", params: [
            "error_message": message,
            "screen": "trackers_main"
        ])
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func updateCreateButtonState() {
        checkSymbolsLimit()
        
        let text = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let symbolsCount = text.count
        let nameIsValid = (1...Constants.symbolsLimit).contains(symbolsCount)
        
        let isEnabled = nameIsValid &&
        !selectedCategory.isEmpty &&
        !selectedEmoji.isEmpty &&
        selectedColor != .systemRed
        
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .ypBlack : .ypGray
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.checkSymbolsLimit()
        }
    }
    
    // MARK: - Abstract Methods (должны быть переопределены)
    func didTapCategoryButton() {
        // Должен быть переопределен
    }
    
    func didTapCancelButton() {
        // Должен быть переопределен
    }
    
    func didTapCreateButton() {
        // Должен быть переопределен
    }
    
    // MARK: - Actions
    @objc func handleTap() {
        view.endEditing(true)
    }
}

// MARK: - EmojiSelectionDelegate
extension BaseTrackerConfigurationViewController: EmojiSelectionDelegate {
    func didSelectEmoji(_ emoji: String) {
        selectedEmoji = emoji
        updateCreateButtonState()
    }
}

// MARK: - ColorSelectionDelegate
extension BaseTrackerConfigurationViewController: ColorSelectionDelegate {
    func didSelectColor(_ color: UIColor) {
        selectedColor = color
        updateCreateButtonState()
    }
}
