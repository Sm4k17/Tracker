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
        static let scheduleTitle = "Расписание"
        static let emojiTitle = "Emoji"
        static let colorTitle = "Цвет"
        
        // Константы для размеров и отступов
        enum Layout {
            static let horizontalInset: CGFloat = 16
            static let verticalSpacing: CGFloat = 12
            static let buttonHeight: CGFloat = 60
            static let cornerRadius: CGFloat = 16
            static let textFieldHeight: CGFloat = 75
            
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
            static let dropdown: UIFont = .systemFont(ofSize: 16, weight: .regular)
        }
        
        // Цвета
        enum Colors {
            static let sectionTitle: UIColor = .ypBlack
            static let buttonText: UIColor = .ypWhite
            static let cancelButtonText: UIColor = .ypRed
            static let dropdownText: UIColor = .ypBlack
            static let dropdownBackground: UIColor = .ypBackgroundDay
        }
    }
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
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
        
        return textField
    }()
    
    private lazy var categoryButton: UIButton = {
        createDropdownButton(title: Constants.categoryTitle) { [weak self] in
            self?.didTapCategoryButton()
        }
    }()
    
    private lazy var scheduleButton: UIButton = {
        createDropdownButton(title: Constants.scheduleTitle) { [weak self] in
            self?.didTapScheduleButton()
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
    private var selectedSchedule: Set<Week> = []
    private var selectedEmoji: String = ""
    private var selectedColor: UIColor = .systemRed
    
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
        setupAutoresizingMasks()
    }
    
    private func setupNavigationBar() {
        title = Constants.navigationTitle
        
        // Убираем кнопку назад
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [nameTextField, categoryButton, scheduleButton, emojiLabel, emojiSelectionView,
         colorLabel, colorSelectionView, cancelButton, createButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupAutoresizingMasks() {
        [scrollView, contentView, nameTextField, categoryButton, scheduleButton,
         emojiSelectionView, colorSelectionView, cancelButton, createButton,
         emojiLabel, colorLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Добавляем стрелочки для кнопок категории и расписания
        if let arrowImageView = categoryButton.subviews.first(where: { $0 is UIImageView }) {
            arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        if let arrowImageView = scheduleButton.subviews.first(where: { $0 is UIImageView }) {
            arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        setupScrollViewConstraints()
        setupNameTextFieldConstraints()
        setupCategoryButtonConstraints()
        setupScheduleButtonConstraints()
        setupEmojiSectionConstraints()
        setupColorSectionConstraints()
        setupButtonsConstraints()
    }
    
    // MARK: - Constraint Setup Methods
    private func setupScrollViewConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
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
    }
    
    private func setupCategoryButtonConstraints() {
        NSLayoutConstraint.activate([
            categoryButton.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: Constants.Layout.verticalSpacing),
            categoryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.horizontalInset),
            categoryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.horizontalInset),
            categoryButton.heightAnchor.constraint(equalToConstant: Constants.Layout.buttonHeight)
        ])
    }
    
    private func setupScheduleButtonConstraints() {
        NSLayoutConstraint.activate([
            scheduleButton.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: Constants.Layout.verticalSpacing),
            scheduleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.horizontalInset),
            scheduleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.horizontalInset),
            scheduleButton.heightAnchor.constraint(equalToConstant: Constants.Layout.buttonHeight)
        ])
    }
    
    private func setupEmojiSectionConstraints() {
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: scheduleButton.bottomAnchor, constant: 32),
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
            colorSelectionView.heightAnchor.constraint(equalToConstant: Constants.Layout.colorCollectionHeight)
        ])
    }
    
    private func setupButtonsConstraints() {
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: colorSelectionView.bottomAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.horizontalInset),
            cancelButton.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -4),
            cancelButton.heightAnchor.constraint(equalToConstant: Constants.Layout.buttonHeight),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            createButton.topAnchor.constraint(equalTo: colorSelectionView.bottomAnchor, constant: 16),
            createButton.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 4),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.horizontalInset),
            createButton.heightAnchor.constraint(equalToConstant: Constants.Layout.buttonHeight),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
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
    
    private func createDropdownButton(title: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = Constants.Fonts.dropdown
        button.backgroundColor = Constants.Colors.dropdownBackground
        button.setTitleColor(Constants.Colors.dropdownText, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        button.layer.cornerRadius = Constants.Layout.cornerRadius
        button.layer.masksToBounds = true
        
        let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowImageView.tintColor = .ypGray
        button.addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            arrowImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16)
        ])
        
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
    
    // MARK: - Actions
    private func didTapCategoryButton() {
        let categoryVC = CategorySelectionViewController(selectedCategory: selectedCategory) { [weak self] category in
            self?.selectedCategory = category
            self?.categoryButton.setTitle(category, for: .normal)
            self?.categoryButton.setTitleColor(.ypBlack, for: .normal)
            self?.updateCreateButtonState()
        }
        navigationController?.pushViewController(categoryVC, animated: true)
    }
    
    private func didTapScheduleButton() {
        let scheduleVC = ScheduleSelectionViewController(selectedDays: selectedSchedule) { [weak self] schedule in
                self?.selectedSchedule = schedule
                let scheduleText: String
                
                if schedule.isEmpty {
                    scheduleText = Constants.scheduleTitle
                } else if schedule.count == 7 {
                    scheduleText = "Каждый день"
                } else {
                    // Сортируем дни недели по порядку (пн, вт, ср, чт, пт, сб, вс)
                    let sortedDays = schedule.sorted { $0.rawValue < $1.rawValue }
                    scheduleText = sortedDays.map { $0.shortTitle }.joined(separator: ", ")
                }
                
                self?.scheduleButton.setTitle(scheduleText, for: .normal)
                self?.scheduleButton.setTitleColor(.ypBlack, for: .normal)
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
            id: UUID(),
            name: trackerName,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: selectedSchedule
        )
        
        delegate?.didCreateNewTracker(habit)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func updateCreateButtonState() {
        let text = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let isEnabled = !text.isEmpty &&
        !selectedCategory.isEmpty &&
        !selectedSchedule.isEmpty &&
        !selectedEmoji.isEmpty
        
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .ypBlack : .ypGray
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
