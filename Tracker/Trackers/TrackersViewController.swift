//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 08.09.2025.
//

import UIKit

// MARK: - Main View Controller
final class TrackersViewController: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let navigationTitle = "Трекеры"
        static let placeholderTitle = "Что будем отслеживать?"
        static let placeholderImageName = "icDizzy"
        static let addButtonImageName = "plus"
        static let searchPlaceholder = "Поиск"
        
        // Константы для размеров и отступов
        enum Layout {
            // Navigation
            static let datePickerWidth: CGFloat = 77
            static let datePickerHeight: CGFloat = 34
            
            // Content
            static let collectionViewTopInset: CGFloat = 16
            
            // Placeholder
            static let placeholderImageSize: CGFloat = 80
            static let placeholderSpacing: CGFloat = 8
            
            // COLLECTION VIEW CONSTANTS
            static let collectionItemSpacing: CGFloat = 12
            static let collectionLineSpacing: CGFloat = 16
            static let collectionSectionInsetTop: CGFloat = 12
            static let collectionSectionInsetLeft: CGFloat = 16
            static let collectionSectionInsetBottom: CGFloat = 16
            static let collectionSectionInsetRight: CGFloat = 16
            static let collectionItemHeight: CGFloat = 148
            static let collectionHeaderHeight: CGFloat = 18
            static let collectionItemsPerRow: CGFloat = 2
            
            // КОНСТАНТЫ ДЛЯ SEARCH CONTROLLER
            static let searchTextFieldCornerRadius: CGFloat = 10
            static let searchTextFieldFontSize: CGFloat = 17
            
            // Вычисляемые константы
            static var collectionTotalHorizontalInset: CGFloat {
                collectionSectionInsetLeft + collectionSectionInsetRight + collectionItemSpacing
            }
        }
        
        // ЦВЕТА ДЛЯ ТЕКСТА
        enum Colors {
            static let searchPlaceholder: UIColor = .ypGray
            static let searchText: UIColor = .ypBlack
            static let dateButtonText: UIColor = .ypBlack
            static let searchBackground: UIColor = .ypGrayS
        }
    }
    
    // MARK: - Properties
    private var categories: [TrackerCategory] = [] {
        didSet {
            // ПРИ ИЗМЕНЕНИИ КАТЕГОРИЙ АВТОМАТИЧЕСКИ ОБНОВЛЯЕМ ФИЛЬТРАЦИЮ
            filterTrackersForCurrentDate()
        }
    }
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date = Date()
    private var filteredCategories: [TrackerCategory] = []
    
    // MARK: - UI Components
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite
        return view
    }()
    
    // Кнопка "+" в левой части navigation bar
    private lazy var addButton: UIBarButtonItem = {
        let buttonImage = UIImage(named: Constants.addButtonImageName) ?? UIImage(systemName: "plus")
        let button = UIBarButtonItem(
            image: buttonImage,
            primaryAction: UIAction { [weak self] _ in
                self?.didTapAddButton()
            }
        )
        button.tintColor = .ypBlack
        return button
    }()
    
    // Основной DatePicker
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.tintColor = .ypBlack
        
        datePicker.addAction(UIAction { [weak self] _ in
            self?.dateChanged(datePicker)
        }, for: .valueChanged)
        
        return datePicker
    }()
    
    // SearchController для поиска трекеров
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = Constants.searchPlaceholder
        searchController.searchBar.delegate = self
        
        return searchController
    }()
    
    // StackView для размещения иконки и текста плейсхолдера
    private lazy var placeholderStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = Constants.Layout.placeholderSpacing
        return stack
    }()
    
    // Иконка плейсхолдера (когда нет трекеров)
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: Constants.placeholderImageName)
        return imageView
    }()
    
    // Текст плейсхолдера
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = .ypBlack
        label.text = Constants.placeholderTitle
        return label
    }()
    
    // CollectionView для отображения списка трекеров
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        // ИСПОЛЬЗУЕМ КОНСТАНТЫ ДЛЯ НАСТРОЙКИ LAYOUT
        layout.minimumInteritemSpacing = Constants.Layout.collectionItemSpacing
        layout.minimumLineSpacing = Constants.Layout.collectionLineSpacing
        layout.sectionInset = UIEdgeInsets(
            top: Constants.Layout.collectionSectionInsetTop,
            left: Constants.Layout.collectionSectionInsetLeft,
            bottom: Constants.Layout.collectionSectionInsetBottom,
            right: Constants.Layout.collectionSectionInsetRight
        )
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .ypWhite
        collection.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collection.register(
            SupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "Header"
        )
        
        // ДОБАВИМ ДЛЯ БУДУЩЕГО ИСПОЛЬЗОВАНИЯ
        collection.showsVerticalScrollIndicator = false
        collection.alwaysBounceVertical = true
        
        return collection
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupCollectionView()
        loadSampleData()
        updatePlaceholderVisibility()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .ypWhite
        setupViews()
        setupConstraints()
        setupTapGesture()
    }
    
    // MARK: - Date Formatter
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.keyboardDismissMode = .onDrag
    }
    
    private func setupNavigationBar() {
        title = Constants.navigationTitle
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        // ✅ НАСТРОЙКА LARGE TITLE
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        // Настройка внешнего вида navigation bar
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.ypBlack,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func setupViews() {
        // Обновленная иерархия
        [contentView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        [placeholderStackView, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        placeholderStackView.addArrangedSubview(placeholderImageView)
        placeholderStackView.addArrangedSubview(placeholderLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            // Content View
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                             constant: Constants.Layout.collectionViewTopInset),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Collection View внутри contentView
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Placeholder Stack View
            placeholderStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Placeholder Image
            placeholderImageView.widthAnchor.constraint(equalToConstant: Constants.Layout.placeholderImageSize),
            placeholderImageView.heightAnchor.constraint(equalToConstant: Constants.Layout.placeholderImageSize),
            
            //datePicker
            datePicker.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    // MARK: - Helper Methods
    private func calculateCollectionViewItemSize() -> CGSize {
        let totalWidth = view.bounds.width - Constants.Layout.collectionTotalHorizontalInset
        let itemWidth = totalWidth / Constants.Layout.collectionItemsPerRow
        
        return CGSize(
            width: itemWidth,
            height: Constants.Layout.collectionItemHeight
        )
    }
    
    private func updatePlaceholderVisibility() {
        let isEmpty = filteredCategories.isEmpty || filteredCategories.allSatisfy { $0.trackers.isEmpty }
        placeholderStackView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    
    private func filterTrackersForCurrentDate() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        
        let systemWeekday = weekday
        let ourWeekday: Week
        
        switch systemWeekday {
        case 1: ourWeekday = .sunday
        case 2: ourWeekday = .monday
        case 3: ourWeekday = .tuesday
        case 4: ourWeekday = .wednesday
        case 5: ourWeekday = .thursday
        case 6: ourWeekday = .friday
        case 7: ourWeekday = .saturday
        default: ourWeekday = .monday
        }
        
        // ФИЛЬТРУЕМ БЕЗ СОЗДАНИЯ ДУБЛИРОВАННЫХ КАТЕГОРИЙ
        filteredCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.scheduleTrackers.isEmpty || tracker.scheduleTrackers.contains(ourWeekday)
            }
            // ВОЗВРАЩАЕМ nil ЕСЛИ НЕТ ТРЕКЕРОВ, ЧТОБЫ ИСКЛЮЧИТЬ ПУСТЫЕ КАТЕГОРИИ
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { record in
            record.trackerId == id && Calendar.current.isDate(record.date, inSameDayAs: currentDate)
        }
    }
    
    private func completedDaysCount(for trackerId: UUID) -> Int {
        completedTrackers.filter { $0.trackerId == trackerId }.count
    }
    
    private func dayString(for count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        
        if lastDigit == 1 && lastTwoDigits != 11 { return "день" }
        if (2...4).contains(lastDigit) && !(12...14).contains(lastTwoDigits) { return "дня" }
        return "дней"
    }
    
    // MARK: - Temporary Sample Data
    private func loadSampleData() {
        let sampleTracker1 = Tracker(
            name: "Пить воду",
            color: .systemBlue,
            emoji: "💧",
            schedule: [.tuesday, .thursday] // Вт, Чт
            //Set(Week.allCases) // Ежедневно
        )
        
        let sampleTracker2 = Tracker(
            name: "Бег",
            color: .systemGreen,
            emoji: "🏃",
            schedule: [.monday, .wednesday, .friday] // Пн, Ср, Пт
        )
        
        let sampleTracker3 = Tracker(
            name: "Читать",
            color: .systemOrange,
            emoji: "📚",
            schedule: [.tuesday, .thursday] // Вт, Чт
        )
        
        let sampleTracker4 = Tracker(
            name: "Спать 8 часов",
            color: .systemPurple,
            emoji: "😴",
            schedule: [.tuesday, .thursday] // Вт, Чт
        )
        
        let sampleTracker5 = Tracker(
            name: "Учить английский",
            color: .systemRed,
            emoji: "📖",
            schedule: [.monday, .tuesday, .thursday, .friday] // Пн, Вт, Чт, Пт
        )
        
        let sampleTracker6 = Tracker(
            name: "Медитация",
            color: .systemIndigo,
            emoji: "🧘",
            schedule: [.saturday] // Сб
        )
        
        let healthCategory = TrackerCategory(
            title: "Здоровье",
            trackers: [sampleTracker1, sampleTracker2, sampleTracker4]
        )
        
        let educationCategory = TrackerCategory(
            title: "Образование",
            trackers: [sampleTracker3, sampleTracker5]
        )
        
        let personalCategory = TrackerCategory(
            title: "Личное",
            trackers: [sampleTracker6]
        )
        
        categories = [healthCategory, educationCategory, personalCategory]
        filterTrackersForCurrentDate()
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
    
    private func didTapAddButton() {
        let creationVC = CreationTrackerViewController(delegate: self)
        let navigationController = UINavigationController(rootViewController: creationVC)
        present(navigationController, animated: true)
    }
    
    private func dateChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Date changed: \(formattedDate)")
        
        currentDate = selectedDate
        filterTrackersForCurrentDate()
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "TrackerCell",
            for: indexPath
        ) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        let isCompletedToday = isTrackerCompletedToday(id: tracker.idTrackers)
        let completedDays = completedDaysCount(for: tracker.idTrackers)
        
        let viewModel = TrackerViewModel(
            tracker: tracker,
            isCompletedToday: isCompletedToday,
            completedDays: completedDays
        )
        
        cell.configure(with: viewModel)
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "Header",
            for: indexPath
        ) as? SupplementaryView else {
            return UICollectionReusableView()
        }
        
        let category = filteredCategories[indexPath.section]
        header.configure(category.title)
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return calculateCollectionViewItemSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: Constants.Layout.collectionHeaderHeight)
    }
}

// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        print("Search text: \(searchText)")
        // Здесь будет логика фильтрации по поиску
    }
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func didTapPlusButton(in cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        let trackerId = tracker.idTrackers
        
        // Проверяем, можно ли отметить трекер на выбранную дату
        let today = Calendar.current.startOfDay(for: Date())
        let selectedDate = Calendar.current.startOfDay(for: currentDate)
        
        guard selectedDate <= today else {
            print("⚠️ Нельзя отметить трекер для будущей даты: \(currentDate)")
            return
        }
        
        // Переключаем состояние выполнения
        if let index = completedTrackers.firstIndex(where: { record in
            record.trackerId == trackerId && Calendar.current.isDate(record.date, inSameDayAs: currentDate)
        }) {
            completedTrackers.remove(at: index)
            print("❌ Удалили запись выполнения")
        } else {
            let record = TrackerRecord(trackerId: trackerId, date: currentDate)
            completedTrackers.append(record)
            print("✅ Добавили запись выполнения")
        }
        
        // Обновляем только нужную ячейку
        collectionView.reloadItems(at: [indexPath])
    }
}

// MARK: - TrackerViewControllerDelegate
extension TrackersViewController: TrackerViewControllerDelegate {
    func didCreateNewTracker(_ tracker: Tracker, categoryTitle: String) {
        dismiss(animated: true)
        
        let finalCategoryTitle = categoryTitle.isEmpty ? "Мои трекеры" : categoryTitle
        
        if let index = categories.firstIndex(where: { $0.title == finalCategoryTitle }) {
            // ОБНОВЛЯЕМ СУЩЕСТВУЮЩУЮ КАТЕГОРИЮ
            let category = categories[index]
            var updatedTrackers = category.trackers
            updatedTrackers.append(tracker)
            categories[index] = TrackerCategory(title: category.title, trackers: updatedTrackers)
        } else {
            // СОЗДАЕМ НОВУЮ КАТЕГОРИЮ - didSet ВЫЗОВЕТ filterTrackersForCurrentDate()
            let newCategory = TrackerCategory(title: finalCategoryTitle, trackers: [tracker])
            categories.append(newCategory)
        }
    }
    
    func didCancelTrackerCreation() {
        dismiss(animated: true)
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview("Trackers View") {
    let viewController = TrackersViewController()
    return UINavigationController(rootViewController: viewController)
}
#endif
