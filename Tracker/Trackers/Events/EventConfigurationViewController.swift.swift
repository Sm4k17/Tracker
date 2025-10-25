//
//  EventConfigurationViewController.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 30.09.2025.
//

import UIKit

// MARK: - Event Configuration View Controller
final class EventConfigurationViewController: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let navigationTitle = "irregular_event".localized
        static let cancelButtonTitle = "cancel".localized
        static let createButtonTitle = "create".localized
        
        static let namePlaceholder = "enter_tracker_name".localized
        static let categoryTitle = "category".localized
        static let categorySubtitle = ""
        static let emojiTitle = "emoji".localized
        static let colorTitle = "color".localized
        static let symbolsLimitMessage = "symbols_limit".localized
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
            static let dropdownBackground: UIColor = .ypBackgroundDay
        }
    }
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 24, left: Constants.Layout.horizontalInset,
                                           bottom: 24, right: Constants.Layout.horizontalInset)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.namePlaceholder
        textField.backgroundColor = .ypBackgroundDay
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
    
    private lazy var symbolsLimitLabel: UILabel = {
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
    
    // Унифицированный контейнер для категории (как в HabitConfigurationViewController)
    private lazy var categoryContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.backgroundColor = Constants.Colors.dropdownBackground
        stack.layer.cornerRadius = Constants.Layout.cornerRadius
        stack.layer.masksToBounds = true
        return stack
    }()
    
    private lazy var categoryButton: UIButton = {
        createDropdownButton(
            title: Constants.categoryTitle,
            subtitle: Constants.categorySubtitle
        ) { [weak self] in
            self?.didTapCategoryButton()
        }
    }()
    
    private lazy var emojiSelectionView: EmojiSelectionView = {
        let view = EmojiSelectionView()
        view.delegate = self
        return view
    }()
    
    private lazy var colorSelectionView: ColorSelectionView = {
        let view = ColorSelectionView()
        view.delegate = self
        return view
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var cancelButton: UIButton = {
        createActionButton(
            title: Constants.cancelButtonTitle,
            backgroundColor: .clear,
            titleColor: Constants.Colors.cancelButtonText,
            borderColor: .ypRed
        ) { [weak self] in
            self?.didTapCancelButton()
        }
    }()
    
    private lazy var createButton: UIButton = {
        createActionButton(
            title: Constants.createButtonTitle,
            backgroundColor: .ypGray,
            titleColor: Constants.Colors.buttonText
        ) { [weak self] in
            self?.didTapCreateButton()
        }
    }()
    
    private lazy var emojiLabel: UILabel = {
        createSectionLabel(text: Constants.emojiTitle)
    }()
    
    private lazy var colorLabel: UILabel = {
        createSectionLabel(text: Constants.colorTitle)
    }()
    
    // MARK: - Properties
    private weak var delegate: TrackerViewControllerDelegate?
    private var selectedCategory: String = ""
    private var selectedEmoji: String = ""
    private var selectedColor: UIColor = .systemRed
    private var showWarningAnimationStarted = false
    private var hideWarningAnimationStarted = false
    
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
        setupTapGesture()
        updateCreateButtonState()
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
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        [nameTextField, symbolsLimitLabel, categoryContainer, emojiLabel,
         emojiSelectionView, colorLabel, colorSelectionView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        
        updateSpacing()
        
        // Добавляем только кнопку категории в контейнер (без разделителя и второй кнопки)
        categoryContainer.addArrangedSubview(categoryButton)
        categoryButton.heightAnchor.constraint(equalToConstant: Constants.Layout.dropdownItemHeight).isActive = true
        
        emojiSelectionView.heightAnchor.constraint(equalToConstant: Constants.Layout.emojiCollectionHeight).isActive = true
        colorSelectionView.heightAnchor.constraint(equalToConstant: Constants.Layout.colorCollectionHeight).isActive = true
        
        view.addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
        
        [emojiLabel, colorLabel, emojiSelectionView, colorSelectionView, categoryButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
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
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Dynamic Spacing Methods
    private func updateSpacing() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if self.symbolsLimitLabel.isHidden {
                // Когда warning скрыт - 24pt между полем и категорией
                self.contentStackView.setCustomSpacing(24, after: self.nameTextField)
            } else {
                // Когда warning виден - 8pt между полем и warning, 24pt между warning и категорией
                self.contentStackView.setCustomSpacing(8, after: self.nameTextField)
                self.contentStackView.setCustomSpacing(24, after: self.symbolsLimitLabel)
            }
        }
    }
    
    // MARK: - Symbols Limit Methods
    private func checkSymbolsLimit() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let symbolsCount = self.nameTextField.text?.count ?? 0
            symbolsCount > Constants.symbolsLimit ? self.showSymbolsLimitLabel() : self.hideSymbolsLimitLabel()
        }
    }
    
    private func showSymbolsLimitLabel() {
        guard !showWarningAnimationStarted && symbolsLimitLabel.isHidden && !hideWarningAnimationStarted else { return }
        showWarningAnimationStarted = true
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            self.symbolsLimitLabel.transform = CGAffineTransform(translationX: 0, y: -10)
            self.symbolsLimitLabel.isHidden = false
            
            // ОБНОВИТЬ SPACING ПЕРЕД АНИМАЦИЕЙ
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
    
    private func hideSymbolsLimitLabel() {
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
                
                // ОБНОВИТЬ SPACING ПОСЛЕ СКРЫТИЯ
                self.updateSpacing()
                
                self.hideWarningAnimationStarted = false
            }
        }
    }
    
    // MARK: - Actions
    @objc private func handleTap() {
        view.endEditing(true)
    }
    
    // MARK: - Factory Methods
    private func createSectionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = Constants.Fonts.sectionTitle
        label.textColor = Constants.Colors.sectionTitle
        return label
    }
    
    private func createDropdownButton(title: String, subtitle: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.contentHorizontalAlignment = .left
        button.layer.masksToBounds = true
        
        // Создаем вертикальный стек для заголовка и подзаголовка
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
        
        // Добавляем стрелочку
        let arrowImageView = UIImageView()
        arrowImageView.image = UIImage(named: "chevron")
        arrowImageView.tintColor = .ypGray
        button.addSubview(arrowImageView)
        
        // Настраиваем констрейнты
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
        
        // Делаем всю кнопку кликабельной
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        
        return button
    }
    
    private func createActionButton(
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
    private func updateCategoryButtonSubtitle(_ subtitle: String) {
        if let textStack = categoryButton.subviews.first(where: { $0 is UIStackView }) as? UIStackView,
           let subtitleLabel = textStack.arrangedSubviews.last as? UILabel {
            subtitleLabel.text = subtitle
            subtitleLabel.textColor = Constants.Colors.dropdownSubtitle
        }
    }
    
    // MARK: - Actions
    private func didTapCategoryButton() {
         let categoryVC = CategorySelectionViewController(selectedCategory: selectedCategory) { [weak self] category in
         self?.selectedCategory = category
         self?.updateCategoryButtonSubtitle(category)
         self?.updateCreateButtonState()
         }
         navigationController?.pushViewController(categoryVC, animated: true)
    }
    
    private func didTapCancelButton() {
        if let creationVC = navigationController?.viewControllers.first(where: { $0 is CreationTrackerViewController }) {
            navigationController?.popToViewController(creationVC, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func didTapCreateButton() {
        guard let trackerName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trackerName.isEmpty else {
            showError(message: "Введите название события")
            return
        }
        
        let symbolsCount = trackerName.count
        guard symbolsCount <= Constants.symbolsLimit else {
            showError(message: "Название не должно превышать \(Constants.symbolsLimit) символов")
            return
        }
        
        guard !selectedEmoji.isEmpty else {
            showError(message: "Выберите emoji")
            return
        }
        
        guard selectedColor != .systemRed else {
            showError(message: "Выберите цвет")
            return
        }
        
        guard !selectedCategory.isEmpty else {
            showError(message: "Выберите категорию")
            return
        }
        
        let event = Tracker(
            idTrackers: UUID(),
            name: trackerName,
            color: selectedColor,
            emoji: selectedEmoji,
            scheduleTrackers: [], // Пустое расписание для событий
            category: selectedCategory
        )
        
        delegate?.didCreateNewTracker(event, categoryTitle: selectedCategory)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func updateCreateButtonState() {
        checkSymbolsLimit()
        let text = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let symbolsCount = text.count
        let nameIsValid = (1...Constants.symbolsLimit).contains(symbolsCount)
        
        let isEnabled = !text.isEmpty &&
        nameIsValid &&
        !selectedCategory.isEmpty &&
        !selectedEmoji.isEmpty &&
        selectedColor != .systemRed
        
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .ypBlack : .ypGray
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.checkSymbolsLimit()
        }
    }
}

// MARK: - EmojiSelectionDelegate
extension EventConfigurationViewController: EmojiSelectionDelegate {
    func didSelectEmoji(_ emoji: String) {
        selectedEmoji = emoji
        updateCreateButtonState()
    }
}

// MARK: - ColorSelectionDelegate
extension EventConfigurationViewController: ColorSelectionDelegate {
    func didSelectColor(_ color: UIColor) {
        selectedColor = color
        updateCreateButtonState()
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview("Event Configuration View") {
    let viewController = EventConfigurationViewController(delegate: nil)
    let navigationController = UINavigationController(rootViewController: viewController)
    return navigationController
}
#endif
