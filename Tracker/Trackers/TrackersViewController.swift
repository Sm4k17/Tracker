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
        static let navigationTitle = R.string.localizable.trackers()
        static let placeholderTitle = R.string.localizable.what_to_track()
        static let searchPlaceholder = R.string.localizable.search()
        
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
    
    // MARK: - Core Data Stores
    private let trackerStore = TrackerStore()
    private let recordStore = TrackerRecordStore()
    
    // MARK: - UI Components
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite
        return view
    }()
    
    // Кнопка "+" в левой части navigation bar
    private lazy var addButton: UIBarButtonItem = {
        let buttonImage = R.image.plus()
        let button = UIBarButtonItem(
            image: buttonImage,
            primaryAction: UIAction { [weak self] _ in
                // Аналитика: пользователь нажал кнопку создания трекера
                AnalyticsService.shared.report(event: "tracker_creation_opened", params: [
                    "screen": "trackers_main",
                    "source": "plus_button"
                ])
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
        datePicker.locale = Locale.current
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
        imageView.image = R.image.icDizzy()
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
        setupStores()
        loadData()
        updatePlaceholderVisibility()
        AnalyticsService.shared.report(event: "screen_opened", params: [
            "screen_name": "trackers_main",
            "screen_class": String(describing: type(of: self))
        ])
    }
    
    private func setupStores() {
        trackerStore.delegate = self
    }
    
    private func loadData() {
        categories = trackerStore.fetchCategories()
        completedTrackers = recordStore.fetchCompletedTrackers()
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
        formatter.locale = Locale.current
        formatter.dateStyle = .short
        formatter.timeStyle = .none
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
        
        if !searchText.isEmpty && isEmpty {
            // Показываем плейсхолдер для пустого поиска
            placeholderLabel.text = "Ничего не найдено"
            placeholderImageView.image = R.image.icSearchEmpty()
        } else if categories.isEmpty {
            // Показываем стандартный плейсхолдер когда нет трекеров вообще
            placeholderLabel.text = Constants.placeholderTitle
            placeholderImageView.image = R.image.icDizzy()
        } else {
            // Показываем плейсхолдер когда нет трекеров на выбранную дату
            placeholderLabel.text = Constants.placeholderTitle
            placeholderImageView.image = R.image.icDizzy()
        }
    }
    
    // MARK: - Properties
    private var searchText: String = ""
    
    private func filterTrackersForCurrentDate() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        
        let ourWeekday: Week
        switch weekday {
        case 1: ourWeekday = .sunday
        case 2: ourWeekday = .monday
        case 3: ourWeekday = .tuesday
        case 4: ourWeekday = .wednesday
        case 5: ourWeekday = .thursday
        case 6: ourWeekday = .friday
        case 7: ourWeekday = .saturday
        default: ourWeekday = .monday
        }
        
        let oldFilteredCategories = filteredCategories
        let newFilteredCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                // Фильтрация по расписанию
                let matchesSchedule = tracker.scheduleTrackers.isEmpty ||
                tracker.scheduleTrackers.contains(ourWeekday)
                
                // Фильтрация по поиску
                let matchesSearch = searchText.isEmpty ||
                tracker.name.lowercased().contains(searchText.lowercased())
                
                return matchesSchedule && matchesSearch
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        // 🔧 СОХРАНЯЕМ ВАШУ ОПТИМИЗИРОВАННУЮ ЛОГИКУ ОБНОВЛЕНИЯ
        if oldFilteredCategories.count != newFilteredCategories.count {
            // Если количество секций изменилось - полный reload
            filteredCategories = newFilteredCategories
            collectionView.reloadData()
        } else {
            // Если количество секций одинаковое - обновляем по секциям
            filteredCategories = newFilteredCategories
            
            var sectionsToReload: [Int] = []
            for section in 0..<newFilteredCategories.count {
                let oldItemsCount = oldFilteredCategories[section].trackers.count
                let newItemsCount = newFilteredCategories[section].trackers.count
                
                if oldItemsCount != newItemsCount {
                    sectionsToReload.append(section)
                }
            }
            
            if !sectionsToReload.isEmpty {
                collectionView.performBatchUpdates {
                    collectionView.reloadSections(IndexSet(sectionsToReload))
                }
            }
        }
        
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
        
        // Принудительно обновляем все видимые ячейки
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
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
            completedDays: completedDays,
            currentDate: currentDate
        )
        
        // Без анимации для первоначальной настройки
        cell.configure(with: viewModel, animated: false)
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
        
        // Сохраняем поисковый запрос
        self.searchText = searchText
        
        // Аналитика
        AnalyticsService.shared.report(event: "search_performed", params: [
            "search_query": searchText,
            "query_length": searchText.count,
            "results_count": filteredCategories.flatMap { $0.trackers }.count
        ])
        
        // Применяем фильтрацию с вашей оптимизированной логикой
        filterTrackersForCurrentDate()
    }
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // При отмене поиска очищаем поисковый запрос
        searchText = ""
        filterTrackersForCurrentDate()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // Если текст очищен, сбрасываем поиск
            self.searchText = ""
            filterTrackersForCurrentDate()
        }
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func didTapPlusButton(in cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        let trackerId = tracker.idTrackers
        
        let today = Calendar.current.startOfDay(for: Date())
        let selectedDate = Calendar.current.startOfDay(for: currentDate)
        
        guard selectedDate <= today else {
            // Аналитика: попытка отметить трекер в будущем
            AnalyticsService.shared.report(event: "tracker_future_date_attempt", params: [
                "tracker_type": tracker.scheduleTrackers.isEmpty ? "event" : "habit",
                "selected_date": dateFormatter.string(from: currentDate)
            ])
            print("⚠️ Нельзя отметить трекер для будущей даты: \(currentDate)")
            return
        }
        
        do {
            let wasCompleted = recordStore.isTrackerCompleted(trackerId: trackerId, date: currentDate)
            
            if wasCompleted {
                try recordStore.removeRecord(trackerId: trackerId, date: currentDate)
                // Аналитика: трекер отмечен как невыполненный
                AnalyticsService.shared.report(event: "tracker_uncompleted", params: [
                    "tracker_type": tracker.scheduleTrackers.isEmpty ? "event" : "habit",
                    "category": tracker.category,
                    "date": dateFormatter.string(from: currentDate)
                ])
            } else {
                try recordStore.addRecord(trackerId: trackerId, date: currentDate)
                // Аналитика: трекер отмечен как выполненный
                AnalyticsService.shared.report(event: "tracker_completed", params: [
                    "tracker_type": tracker.scheduleTrackers.isEmpty ? "event" : "habit",
                    "category": tracker.category,
                    "date": dateFormatter.string(from: currentDate)
                ])
            }
            
            // Обновляем completedTrackers из Core Data
            completedTrackers = recordStore.fetchCompletedTrackers()
            
            // 🔒 БЕЗОПАСНО: Обновляем только одну ячейку
            collectionView.performBatchUpdates {
                if let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell {
                    let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
                    let isCompletedToday = recordStore.isTrackerCompleted(trackerId: trackerId, date: currentDate)
                    let completedDays = recordStore.completedDaysCount(for: trackerId)
                    
                    let viewModel = TrackerViewModel(
                        tracker: tracker,
                        isCompletedToday: isCompletedToday,
                        completedDays: completedDays,
                        currentDate: currentDate
                    )
                    
                    cell.configure(with: viewModel, animated: true)
                }
            }
        } catch {
            // Аналитика: ошибка при обновлении трекера
            AnalyticsService.shared.report(event: "tracker_update_error", params: [
                "error": error.localizedDescription
            ])
            print("❌ Error updating record: \(error)")
            showErrorAlert(message: "Не удалось обновить статус трекера")
        }
    }
}

// MARK: - TrackerViewControllerDelegate
extension TrackersViewController: TrackerViewControllerDelegate {
    func didCreateNewTracker(_ tracker: Tracker, categoryTitle: String) {
        dismiss(animated: true)
        
        let finalCategoryTitle = categoryTitle.isEmpty ? "Мои трекеры" : categoryTitle
        
        do {
            // Сохраняем трекер в Core Data
            try trackerStore.createTracker(tracker, categoryTitle: finalCategoryTitle)
            
            // Данные автоматически обновятся через делегат TrackerStoreDelegate
            // в методе didUpdateTrackers()
            
        } catch {
            print("❌ Error creating tracker: \(error)")
            showErrorAlert(message: "Не удалось создать трекер")
        }
    }
    
    private func showErrorAlert(message: String) {
        AnalyticsService.shared.report(event: "error_occurred", params: [
            "error_message": message,
            "screen": "trackers_main"
        ])
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
    func didUpdateTrackers() {
        // Обновляем данные из Core Data
        categories = trackerStore.fetchCategories()
        completedTrackers = recordStore.fetchCompletedTrackers()
        
        // filterTrackersForCurrentDate() автоматически вызовется через didSet categories
        // collectionView обновится через наблюдатель в filterTrackersForCurrentDate()
        
        updatePlaceholderVisibility()
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
