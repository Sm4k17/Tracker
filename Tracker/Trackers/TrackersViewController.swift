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
            
            // Filter Button
            static let filterButtonWidth: CGFloat = 114
            static let filterButtonHeight: CGFloat = 50
            static let filterButtonBottomInset: CGFloat = 16
            
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
    
    private var completedTrackers: [TrackerRecord] = [] {
        didSet {
            // Автоматическое обновление при изменении статусов трекеров
            filterTrackersForCurrentDate()
        }
    }
    
    private var currentDate: Date = Date()
    private var currentFilter: TrackerFilter = .all
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
    
    // Кнопка фильтра
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Фильтры", for: .normal)
        button.backgroundColor = .ypBlue
        button.setTitleColor(UIColor(named: "ypWhite"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        
        button.addAction(UIAction { [weak self] _ in
            self?.didTapFilterButton()
        }, for: .touchUpInside)
        
        return button
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
        loadCurrentFilter()
        setupUI()
        setupNavigationBar()
        setupCollectionView()
        setupStores()
        loadData()
        updatePlaceholderVisibility()
        updateFilterButtonVisibility()
        updateFilterButtonAppearance()
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
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
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
        
        [placeholderStackView, collectionView, filterButton].forEach {
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
            datePicker.widthAnchor.constraint(equalToConstant: 100),
            
            // Filter Button
            filterButton.widthAnchor.constraint(equalToConstant: Constants.Layout.filterButtonWidth),
            filterButton.heightAnchor.constraint(equalToConstant: Constants.Layout.filterButtonHeight),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                 constant: -Constants.Layout.filterButtonBottomInset),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
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
        
        if isEmpty {
            if !searchText.isEmpty {
                placeholderLabel.text = "Ничего не найдено"
                placeholderImageView.image = R.image.icSearchEmpty()
            } else if currentFilter == .completed || currentFilter == .uncompleted {
                placeholderLabel.text = "Ничего не найдено"
                placeholderImageView.image = R.image.icStatsEmpty() ?? R.image.icDizzy()
            } else {
                placeholderLabel.text = Constants.placeholderTitle
                placeholderImageView.image = R.image.icDizzy()
            }
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
        let newFilteredCategories = TrackerFilterService.filterTrackers(
            categories: categories,
            currentFilter: currentFilter,
            completedTrackers: completedTrackers,
            currentDate: currentDate,
            searchText: searchText,
            weekday: ourWeekday
        )
        
        // Оптимизированная логика обновления
        if oldFilteredCategories.count != newFilteredCategories.count {
            filteredCategories = newFilteredCategories
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } else {
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
                DispatchQueue.main.async {
                    self.collectionView.performBatchUpdates {
                        self.collectionView.reloadSections(IndexSet(sectionsToReload))
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.updatePlaceholderVisibility()
            self.updateFilterButtonVisibility()
        }
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
    
    // MARK: - Filter Persistence
    private func saveCurrentFilter() {
        let filterValue: Int
        switch currentFilter {
        case .all: filterValue = 0
        case .today: filterValue = 1
        case .completed: filterValue = 2
        case .uncompleted: filterValue = 3
        }
        UserDefaults.standard.set(filterValue, forKey: "currentTrackerFilter")
    }
    
    private func loadCurrentFilter() {
        let savedFilterValue = UserDefaults.standard.integer(forKey: "currentTrackerFilter")
        switch savedFilterValue {
        case 1: currentFilter = .today
        case 2: currentFilter = .completed
        case 3: currentFilter = .uncompleted
        default: currentFilter = .all
        }
    }
    
    // MARK: - Filter Methods
    private func updateFilterButtonVisibility() {
        // Проверяем, есть ли трекеры на выбранную дату (с учетом расписания)
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
        
        let hasTrackersForCurrentDate = categories.contains { category in
            category.trackers.contains { tracker in
                // Проверяем, должен ли трекер отображаться на выбранную дату
                let matchesSchedule = tracker.scheduleTrackers.isEmpty ||
                tracker.scheduleTrackers.contains(ourWeekday)
                return matchesSchedule
            }
        }
        
        filterButton.isHidden = !hasTrackersForCurrentDate
    }
    
    private func updateFilterButtonAppearance() {
        // Красный цвет только для фильтров "Завершенные" и "Не завершенные"
        let isFilterActive = currentFilter == .completed || currentFilter == .uncompleted
        filterButton.setTitleColor(isFilterActive ? .ypRed : .white, for: .normal)
        filterButton.alpha = isFilterActive ? 0.9 : 1.0
    }
    
    private func applyFilter(_ filter: TrackerFilter) {
        _ = currentFilter
        
        switch filter {
        case .today:
            // Для "Трекеры на сегодня" сбрасываем фильтр на .all
            currentFilter = .all
            let today = Date()
            currentDate = today
            datePicker.date = today
            
            // Принудительно обновляем completedTrackers для новой даты
            completedTrackers = recordStore.fetchCompletedTrackers()
            
        case .all, .completed, .uncompleted:
            // Для этих фильтров не меняем дату
            currentFilter = filter
        }
        
        saveCurrentFilter()
        
        // ОБНОВЛЯЕМ UI в главном потоке
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if filter == .today {
                self.completedTrackers = self.recordStore.fetchCompletedTrackers()
            }
            
            self.filterTrackersForCurrentDate()
            self.updateFilterButtonAppearance()
        }
        
        AnalyticsService.shared.report(event: "filter_applied", params: [
            "filter_type": String(describing: filter),
            "screen": "trackers_main"
        ])
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
        
        // сбрасываем фильтр только если был активен фильтр "Трекеры на сегодня"
        if currentFilter == .today {
            currentFilter = .all
            saveCurrentFilter()
            updateFilterButtonAppearance()
        }
        
        // ОБНОВЛЯЕМ completedTrackers в главном потоке
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.completedTrackers = self.recordStore.fetchCompletedTrackers()
            // Всегда обновляем фильтрацию при смене даты
            self.filterTrackersForCurrentDate()
            // Обновляем видимость кнопки фильтра
            self.updateFilterButtonVisibility()
        }
    }
    
    private func didTapFilterButton() {
        let filtersVC = TrackerFiltersViewController(selectedFilter: currentFilter)
        filtersVC.onFilterSelected = { [weak self] filter in
            guard let self = self else { return }
            self.applyFilter(filter)
        }
        
        let navigationController = UINavigationController(rootViewController: filtersVC)
        navigationController.modalPresentationStyle = .pageSheet
        navigationController.isModalInPresentation = false
        present(navigationController, animated: true)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let _ = scrollView.contentSize.height
        let _ = scrollView.frame.size.height
        
        // Показываем/скрываем кнопку фильтра при скролле
        if offsetY > 100 {
            // Если пользователь прокрутил вниз, скрываем кнопку
            UIView.animate(withDuration: 0.3) {
                self.filterButton.alpha = 0.0
            }
        } else {
            // Показываем кнопку когда вверху
            UIView.animate(withDuration: 0.3) {
                self.filterButton.alpha = 1.0
            }
        }
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
            
            // Обновляем completedTrackers из Core Data в главном потоке
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.completedTrackers = self.recordStore.fetchCompletedTrackers()
                
                // полностью перезагружаем данные, так как трекер может изменить свой статус
                // и перестать соответствовать текущему фильтру
                if self.currentFilter == .completed || self.currentFilter == .uncompleted {
                    // Полностью перезагружаем данные и collectionView
                    self.filterTrackersForCurrentDate()
                } else {
                    // 🔒 БЕЗОПАСНО: Обновляем только одну ячейку если фильтр не активен
                    self.collectionView.performBatchUpdates {
                        if let cell = self.collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell {
                            let tracker = self.filteredCategories[indexPath.section].trackers[indexPath.row]
                            let isCompletedToday = self.recordStore.isTrackerCompleted(trackerId: trackerId, date: self.currentDate)
                            let completedDays = self.recordStore.completedDaysCount(for: trackerId)
                            
                            let viewModel = TrackerViewModel(
                                tracker: tracker,
                                isCompletedToday: isCompletedToday,
                                completedDays: completedDays,
                                currentDate: self.currentDate
                            )
                            
                            cell.configure(with: viewModel, animated: true)
                        }
                    }
                }
            }
        } catch {
            // Аналитика: ошибка при обновлении трекера
            AnalyticsService.shared.report(event: "tracker_update_error", params: [
                "error": error.localizedDescription
            ])
            print("❌ Error updating record: \(error)")
            DispatchQueue.main.async {
                self.showErrorAlert(message: "Не удалось обновить статус трекера")
            }
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
        // ОБНОВЛЯЕМ В ГЛАВНОМ ПОТОКЕ
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.categories = self.trackerStore.fetchCategories()
            self.completedTrackers = self.recordStore.fetchCompletedTrackers()
            
            // filterTrackersForCurrentDate() автоматически вызовется через didSet categories
            // collectionView обновится через наблюдатель в filterTrackersForCurrentDate()
            
            self.updatePlaceholderVisibility()
            self.updateFilterButtonVisibility()
            self.updateFilterButtonAppearance()
        }
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
