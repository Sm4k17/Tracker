//
//  HabitConfigurationViewController.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 30.09.2025.
//

import UIKit

// MARK: - Habit Configuration View Controller
final class HabitConfigurationViewController: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let navigationTitle = "Новая привычка"
        static let cancelButtonTitle = "Отмена"
        static let createButtonTitle = "Создать"
        
        static let namePlaceholder = "Введите название трекера"
        static let categoryTitle = "Категория"
        static let categorySubtitle = ""
        static let scheduleTitle = "Расписание"
        static let scheduleSubtitle = ""
        static let emojiTitle = "Emoji"
        static let colorTitle = "Цвет"
        static let symbolsLimitMessage = "Ограничение 38 символов"
        static let symbolsLimit = 38
        
        // Константы для размеров и отступов
        enum Layout {
            static let horizontalInset: CGFloat = 16
            static let verticalSpacing: CGFloat = 12
            static let buttonHeight: CGFloat = 60
            static let cornerRadius: CGFloat = 16
            static let textFieldHeight: CGFloat = 75
            static let separatorHeight: CGFloat = 0.5
            static let dropdownItemHeight: CGFloat = 75
            static let separatorInset: CGFloat = 16
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
            static let separatorColor: UIColor = .ypGray
        }
    }
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // Вертикальный стек для категории и расписания
    private lazy var categoryScheduleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.backgroundColor = Constants.Colors.dropdownBackground
        stack.layer.cornerRadius = Constants.Layout.cornerRadius
        stack.layer.masksToBounds = true
        stack.translatesAutoresizingMaskIntoConstraints = false
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
    
    private lazy var scheduleButton: UIButton = {
        createDropdownButton(
            title: Constants.scheduleTitle,
            subtitle: Constants.scheduleSubtitle
        ) { [weak self] in
            self?.didTapScheduleButton()
        }
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.Colors.separatorColor
        
        // Создаем контейнер для разделителя с отступами
        let container = UIView()
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Constants.Layout.separatorInset),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Constants.Layout.separatorInset),
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            view.heightAnchor.constraint(equalToConstant: Constants.Layout.separatorHeight)
        ])
        
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private lazy var emojiSelectionView: EmojiSelectionView = {
        let view = EmojiSelectionView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var colorSelectionView: ColorSelectionView = {
        let view = ColorSelectionView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
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
    
    private lazy var symbolsLimitLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRed
        label.text = Constants.symbolsLimitMessage
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties
    private weak var delegate: TrackerViewControllerDelegate?
    private var selectedCategory: String = ""
    private var selectedSchedule: Set<Week> = []
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
        scrollView.addSubview(contentView)
        
        [nameTextField, symbolsLimitLabel, categoryScheduleStack, emojiLabel, emojiSelectionView,
         colorLabel, colorSelectionView].forEach {
            contentView.addSubview($0)
        }
        
        // Добавляем кнопки и разделитель в стек
        categoryScheduleStack.addArrangedSubview(categoryButton)
        categoryScheduleStack.addArrangedSubview(separatorView)
        categoryScheduleStack.addArrangedSubview(scheduleButton)
        
        // Настраиваем высоты для элементов стека
        categoryButton.heightAnchor.constraint(equalToConstant: Constants.Layout.dropdownItemHeight).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: Constants.Layout.separatorHeight).isActive = true
        scheduleButton.heightAnchor.constraint(equalToConstant: Constants.Layout.dropdownItemHeight).isActive = true
        
        // Добавляем стек с кнопками отдельно от скролла
        view.addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
        
        // Настраиваем автолейаут для лейблов
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        setupScrollViewConstraints()
        setupNameTextFieldConstraints()
        setupCategoryScheduleStackConstraints()
        setupEmojiSectionConstraints()
        setupColorSectionConstraints()
        setupButtonsConstraints()
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func handleTap() {
        view.endEditing(true)
    }
    
    // MARK: - Constraint Setup Methods
    private func setupScrollViewConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupNameTextFieldConstraints() {
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.horizontalInset),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.horizontalInset)
        ])
        
        NSLayoutConstraint.activate([
            symbolsLimitLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            symbolsLimitLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.horizontalInset),
            symbolsLimitLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.horizontalInset),
            symbolsLimitLabel.heightAnchor.constraint(equalToConstant: Constants.Layout.symbolsLimitLabelHeight)
        ])
    }
    
    private func setupCategoryScheduleStackConstraints() {
        NSLayoutConstraint.activate([
            categoryScheduleStack.topAnchor.constraint(equalTo: symbolsLimitLabel.bottomAnchor, constant: Constants.Layout.verticalSpacing),
            categoryScheduleStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.horizontalInset),
            categoryScheduleStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.horizontalInset)
        ])
    }
    
    private func setupEmojiSectionConstraints() {
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: categoryScheduleStack.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.horizontalInset),
            
            emojiSelectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 16),
            emojiSelectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.horizontalInset),
            emojiSelectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.horizontalInset),
            emojiSelectionView.heightAnchor.constraint(equalToConstant: Constants.Layout.emojiCollectionHeight)
        ])
    }
    
    private func setupColorSectionConstraints() {
        NSLayoutConstraint.activate([
            colorLabel.topAnchor.constraint(equalTo: emojiSelectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.horizontalInset),
            
            colorSelectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 16),
            colorSelectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.horizontalInset),
            colorSelectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.horizontalInset),
            colorSelectionView.heightAnchor.constraint(equalToConstant: Constants.Layout.colorCollectionHeight),
            colorSelectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupButtonsConstraints() {
        NSLayoutConstraint.activate([
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.horizontalInset),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.horizontalInset),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: Constants.Layout.buttonHeight)
        ])
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
        button.translatesAutoresizingMaskIntoConstraints = false
        
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
        button.translatesAutoresizingMaskIntoConstraints = false
        
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
            // Используем тот же цвет что и для заголовка
            subtitleLabel.textColor = Constants.Colors.dropdownSubtitle
        }
    }
    
    private func updateScheduleButtonSubtitle(_ subtitle: String) {
        if let textStack = scheduleButton.subviews.first(where: { $0 is UIStackView }) as? UIStackView,
           let subtitleLabel = textStack.arrangedSubviews.last as? UILabel {
            subtitleLabel.text = subtitle
            // Используем тот же цвет что и для заголовка
            subtitleLabel.textColor = Constants.Colors.dropdownSubtitle
        }
    }
    
    // MARK: - Symbols Limit Methods
    private func checkSymbolsLimit() {
        let symbolsCount = nameTextField.text?.count ?? 0
        symbolsCount > Constants.symbolsLimit ? showSymbolsLimitLabel() : hideSymbolsLimitLabel()
    }
    
    private func showSymbolsLimitLabel() {
        guard !showWarningAnimationStarted && symbolsLimitLabel.isHidden && !hideWarningAnimationStarted else { return }
        showWarningAnimationStarted = true
        symbolsLimitLabel.transform = CGAffineTransform(translationX: 0, y: -10)
        symbolsLimitLabel.alpha = 0
        symbolsLimitLabel.isHidden = false
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self else { return }
            self.symbolsLimitLabel.transform = .identity
            self.symbolsLimitLabel.alpha = 1
            self.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            guard let self else { return }
            self.showWarningAnimationStarted = false
        })
    }
    
    private func hideSymbolsLimitLabel() {
        guard !hideWarningAnimationStarted && !symbolsLimitLabel.isHidden && !showWarningAnimationStarted else { return }
        hideWarningAnimationStarted = true
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let self else { return }
            self.symbolsLimitLabel.alpha = 0
            self.symbolsLimitLabel.isHidden = true
            self.symbolsLimitLabel.transform = CGAffineTransform(translationX: 0, y: -10)
            self.view.layoutIfNeeded()
        }) { [weak self] _ in
            guard let self else { return }
            self.symbolsLimitLabel.isHidden = true
            self.symbolsLimitLabel.transform = .identity
            self.hideWarningAnimationStarted = false
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
    
    private func didTapScheduleButton() {
        let scheduleVC = ScheduleSelectionViewController(selectedDays: selectedSchedule) { [weak self] schedule in
            self?.selectedSchedule = schedule
            let scheduleText: String
            
            if schedule.isEmpty {
                scheduleText = "" // Пустая строка вместо "Не выбрано"
            } else if schedule.count == 7 {
                scheduleText = "Каждый день"
            } else {
                // Сортируем дни недели по порядку (пн, вт, ср, чт, пт, сб, вс)
                let sortedDays = schedule.sorted { $0.rawValue < $1.rawValue }
                scheduleText = sortedDays.map { $0.shortTitle }.joined(separator: ", ")
            }
            
            self?.updateScheduleButtonSubtitle(scheduleText)
            self?.updateCreateButtonState()
        }
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
    
    private func didTapCancelButton() {
        if let creationVC = navigationController?.viewControllers.first(where: { $0 is CreationTrackerViewController }) {
            navigationController?.popToViewController(creationVC, animated: true)
        } else {
            // Если не нашли CreationTrackerViewController, просто pop
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func didTapCreateButton() {
        guard let trackerName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trackerName.isEmpty else {
            showError(message: "Введите название привычки")
            return
        }
        
        let symbolsCount = trackerName.count
        guard symbolsCount <= Constants.symbolsLimit else {
            showError(message: "Название не должно превышать \(Constants.symbolsLimit) символов")
            return
        }
        
        guard !selectedSchedule.isEmpty else {
            showError(message: "Выберите расписание")
            return
        }
        
        guard !selectedEmoji.isEmpty else {
            showError(message: "Выберите emoji")
            return
        }
        
        guard !selectedCategory.isEmpty else {
            showError(message: "Выберите категорию")
            return
        }
        
        let habit = Tracker(
            idTrackers: UUID(),
            name: trackerName,
            color: selectedColor,
            emoji: selectedEmoji,
            scheduleTrackers: selectedSchedule,
            category: selectedCategory
        )
        
        delegate?.didCreateNewTracker(habit, categoryTitle: selectedCategory)
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
        
        let isEnabled = nameIsValid &&
        !selectedCategory.isEmpty &&
        !selectedSchedule.isEmpty &&
        !selectedEmoji.isEmpty
        
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .ypBlack : .ypGray
        
        // Повторная проверка через секунду на случай наложения анимаций
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.checkSymbolsLimit()
        }
    }
}

// MARK: - EmojiSelectionDelegate
extension HabitConfigurationViewController: EmojiSelectionDelegate {
    func didSelectEmoji(_ emoji: String) {
        selectedEmoji = emoji
        updateCreateButtonState()
    }
}

// MARK: - ColorSelectionDelegate
extension HabitConfigurationViewController: ColorSelectionDelegate {
    func didSelectColor(_ color: UIColor) {
        selectedColor = color
        updateCreateButtonState()
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview("Habit Configuration View") {
    let viewController = HabitConfigurationViewController(delegate: nil)
    let navigationController = UINavigationController(rootViewController: viewController)
    return navigationController
}
#endif
