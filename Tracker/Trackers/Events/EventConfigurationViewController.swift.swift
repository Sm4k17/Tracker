//
//  EventConfigurationViewController.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 30.09.2025.
//

import UIKit

// MARK: - Event Configuration View Controller
final class EventConfigurationViewController: BaseTrackerConfigurationViewController {
    
    // MARK: - Override Properties
    override var navigationTitle: String {
        return trackerToEdit != nil ? "Редактирование события" : R.string.localizable.irregular_event()
    }
    
    override var createButtonTitle: String {
        return trackerToEdit != nil ? "Сохранить" : R.string.localizable.create()
    }
    
    // MARK: - Initializer
    override init(trackerToEdit: Tracker? = nil, delegate: TrackerViewControllerDelegate?) {
        super.init(trackerToEdit: trackerToEdit, delegate: delegate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Аналитика: открытие экрана создания
        let screenName = trackerToEdit != nil ? "EditEvent" : "NewEvent"
        AnalyticsService.shared.report(event: "open", params: [
            "screen": screenName
        ])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            let screenName = trackerToEdit != nil ? "EditEvent" : "NewEvent"
            AnalyticsService.shared.report(event: "close", params: [
                "screen": screenName
            ])
        }
    }
    
    // MARK: - Override Setup Methods
    override func setupContentStack() {
        [nameTextField, symbolsLimitLabel, categoryContainer, emojiLabel,
         emojiSelectionView, colorLabel, colorSelectionView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        
        updateSpacing()
        
        // Для событий используем простой контейнер категории
        categoryContainer.addArrangedSubview(categoryButton)
        categoryButton.heightAnchor.constraint(equalToConstant: Constants.Layout.dropdownItemHeight).isActive = true
    }
    
    // MARK: - Override Action Methods
    override func didTapCategoryButton() {
        
        let categoryVC = CategorySelectionViewController(selectedCategory: selectedCategory) { [weak self] category in
            self?.selectedCategory = category
            self?.updateCategoryButtonSubtitle(category)
            self?.updateCreateButtonState()
        }
        navigationController?.pushViewController(categoryVC, animated: true)
    }
    
    override func didTapCancelButton() {
        if let creationVC = navigationController?.viewControllers.first(where: { $0 is CreationTrackerViewController }) {
            navigationController?.popToViewController(creationVC, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func didTapCreateButton() {
        // Аналитика: создание/сохранение трекера
        let action = trackerToEdit != nil ? "save" : "create"
        AnalyticsService.shared.report(event: "click", params: [
            "screen": "NewEvent",
            "item": action
        ])
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
        
        let tracker: Tracker
        if let existingTracker = trackerToEdit {
            // Редактируем существующий трекер
            tracker = Tracker(
                idTrackers: existingTracker.idTrackers,
                name: trackerName,
                color: selectedColor,
                emoji: selectedEmoji,
                scheduleTrackers: [], // Пустое расписание для событий
                category: selectedCategory,
                isPinned: existingTracker.isPinned
            )
            
        } else {
            // Создаем новый трекер
            tracker = Tracker(
                idTrackers: UUID(),
                name: trackerName,
                color: selectedColor,
                emoji: selectedEmoji,
                scheduleTrackers: [], // Пустое расписание для событий
                category: selectedCategory
            )
            
        }
        
        if trackerToEdit != nil {
            delegate?.didUpdateTracker(tracker, categoryTitle: selectedCategory)
        } else {
            delegate?.didCreateNewTracker(tracker, categoryTitle: selectedCategory)
        }
    }
    
    // MARK: - Override Validation
    override func updateCreateButtonState() {
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
