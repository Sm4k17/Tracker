//
//  HabitConfigurationViewController.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 30.09.2025.
//

import UIKit

// MARK: - Habit Configuration View Controller
final class HabitConfigurationViewController: BaseTrackerConfigurationViewController {
    
    // MARK: - Habit-specific Constants
    private enum HabitConstants {
        static let scheduleTitle = R.string.localizable.schedule()
        static let scheduleSubtitle = ""
        
        enum Layout {
            static let separatorHeight: CGFloat = 0.5
            static let separatorInset: CGFloat = 16
        }
    }
    
    // MARK: - Habit-specific UI Components
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
    
    private lazy var scheduleButton: UIButton = {
        createDropdownButton(
            title: HabitConstants.scheduleTitle,
            subtitle: HabitConstants.scheduleSubtitle
        ) { [weak self] in
            self?.didTapScheduleButton()
        }
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        
        let container = UIView()
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: HabitConstants.Layout.separatorInset),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -HabitConstants.Layout.separatorInset),
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            view.heightAnchor.constraint(equalToConstant: HabitConstants.Layout.separatorHeight)
        ])
        
        return container
    }()
    
    // MARK: - Habit-specific Properties
    private var selectedSchedule: Set<Week> = []
    
    // MARK: - Override Properties
    override var navigationTitle: String {
        return trackerToEdit != nil ? R.string.localizable.edit_habit() : R.string.localizable.new_habit()
    }
    
    override var createButtonTitle: String {
        return trackerToEdit != nil ? R.string.localizable.save() : R.string.localizable.create()
    }
    
    // MARK: - Initializer
    override init(trackerToEdit: Tracker? = nil, delegate: TrackerViewControllerDelegate?) {
        super.init(trackerToEdit: trackerToEdit, delegate: delegate)
        
        if let tracker = trackerToEdit {
            setupHabitEditingData(tracker)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Аналитика: открытие экрана создания
        let screenName = trackerToEdit != nil ? "EditHabit" : "NewHabit"
        AnalyticsService.shared.report(event: "open", params: [
            "screen": screenName
        ])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            let screenName = trackerToEdit != nil ? "EditHabit" : "NewHabit"
            AnalyticsService.shared.report(event: "close", params: [
                "screen": screenName
            ])
        }
    }
    
    // MARK: - Override Setup Methods
    override func setupContentStack() {
        [nameTextField, symbolsLimitLabel, categoryScheduleStack, emojiLabel,
         emojiSelectionView, colorLabel, colorSelectionView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        
        updateSpacing()
        
        // Настраиваем стек категории и расписания
        categoryScheduleStack.addArrangedSubview(categoryButton)
        categoryScheduleStack.addArrangedSubview(separatorView)
        categoryScheduleStack.addArrangedSubview(scheduleButton)
        
        categoryButton.heightAnchor.constraint(equalToConstant: Constants.Layout.dropdownItemHeight).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: HabitConstants.Layout.separatorHeight).isActive = true
        scheduleButton.heightAnchor.constraint(equalToConstant: Constants.Layout.dropdownItemHeight).isActive = true
    }
    
    override func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        setupContentStack()
        
        emojiSelectionView.heightAnchor.constraint(equalToConstant: Constants.Layout.emojiCollectionHeight).isActive = true
        colorSelectionView.heightAnchor.constraint(equalToConstant: Constants.Layout.colorCollectionHeight).isActive = true
        
        view.addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
    }
    
    // MARK: - Habit-specific Setup
    private func setupHabitEditingData(_ tracker: Tracker) {
        selectedSchedule = tracker.scheduleTrackers
        let scheduleText = formatScheduleText(tracker.scheduleTrackers)
        updateScheduleButtonSubtitle(scheduleText)
    }
    
    override func setupEditingData(_ tracker: Tracker) {
        super.setupEditingData(tracker)
        setupHabitEditingData(tracker)
    }
    
    // MARK: - Helper Methods
    private func formatScheduleText(_ schedule: Set<Week>) -> String {
        if schedule.isEmpty {
            return ""
        } else if schedule.count == 7 {
            return R.string.localizable.every_day()
        } else {
            let sortedDays = schedule.sorted { $0.rawValue < $1.rawValue }
            return sortedDays.map { $0.localizedShortTitle }.joined(separator: ", ")
        }
    }
    
    private func updateScheduleButtonSubtitle(_ subtitle: String) {
        if let textStack = scheduleButton.subviews.first(where: { $0 is UIStackView }) as? UIStackView,
           let subtitleLabel = textStack.arrangedSubviews.last as? UILabel {
            subtitleLabel.text = subtitle
            subtitleLabel.textColor = Constants.Colors.dropdownSubtitle
        }
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
            "screen": "NewHabit",
            "item": action
        ])
        guard let trackerName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trackerName.isEmpty else {
            showError(message: R.string.localizable.enter_habit_name())
            return
        }
        
        let symbolsCount = trackerName.count
        guard symbolsCount <= Constants.symbolsLimit else {
            showError(message: "Название не должно превышать \(Constants.symbolsLimit) символов")
            return
        }
        
        guard !selectedSchedule.isEmpty else {
            showError(message: R.string.localizable.select_schedule())
            return
        }
        
        guard !selectedEmoji.isEmpty else {
            showError(message: R.string.localizable.select_emoji())
            return
        }
        
        guard selectedColor != .systemRed else {
            showError(message: R.string.localizable.select_color())
            return
        }
        
        guard !selectedCategory.isEmpty else {
            showError(message: R.string.localizable.select_category())
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
                scheduleTrackers: selectedSchedule,
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
                scheduleTrackers: selectedSchedule,
                category: selectedCategory
            )
            
        }
        
        if trackerToEdit != nil {
            delegate?.didUpdateTracker(tracker, categoryTitle: selectedCategory)
        } else {
            delegate?.didCreateNewTracker(tracker, categoryTitle: selectedCategory)
        }
    }
    
    // MARK: - Habit-specific Actions
    private func didTapScheduleButton() {
        
        let scheduleVC = ScheduleSelectionViewController(selectedDays: selectedSchedule) { [weak self] schedule in
            self?.selectedSchedule = schedule
            let scheduleText: String
            
            if schedule.isEmpty {
                scheduleText = ""
            } else if schedule.count == 7 {
                scheduleText = R.string.localizable.every_day()
            } else {
                let sortedDays = schedule.sorted { $0.rawValue < $1.rawValue }
                scheduleText = sortedDays.map { $0.localizedShortTitle }.joined(separator: ", ")
            }
            
            self?.updateScheduleButtonSubtitle(scheduleText)
            self?.updateCreateButtonState()
        }
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
    
    // MARK: - Override Validation
    override func updateCreateButtonState() {
        checkSymbolsLimit()
        
        let text = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let symbolsCount = text.count
        let nameIsValid = (1...Constants.symbolsLimit).contains(symbolsCount)
        
        let isEnabled = nameIsValid &&
        !selectedCategory.isEmpty &&
        !selectedSchedule.isEmpty &&
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
#Preview("Habit Configuration View") {
    let viewController = HabitConfigurationViewController(delegate: nil)
    let navigationController = UINavigationController(rootViewController: viewController)
    return navigationController
}
#endif
