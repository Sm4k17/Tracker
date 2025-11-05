//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 08.09.2025.
//

//
// TrackersDataSource - отвечает за данные и фильтрацию
// TrackersLayoutCalculator - отвечает за вычисление layout
// TrackersPlaceholderManager - отвечает за управление плейсхолдером
// TrackersViewController становится тонким координатором
//

import UIKit

// MARK: - Main View Controller
final class TrackersViewController: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let navigationTitle = R.string.localizable.trackers()
        static let placeholderTitle = R.string.localizable.what_to_track()
        static let searchPlaceholder = R.string.localizable.search()
        
        // Layout Constants
        enum Layout {
            static let placeholderImageSize: CGFloat = 80
            static let placeholderSpacing: CGFloat = 8
            static let filterButtonWidth: CGFloat = 114
            static let filterButtonHeight: CGFloat = 50
            static let filterButtonBottomInset: CGFloat = 16
            static let datePickerWidth: CGFloat = 100
        }
    }
    
    // MARK: - Properties
    private var categories: [TrackerCategory] = [] {
        didSet {
            filterTrackersForCurrentDate()
        }
    }
    
    private var completedTrackers: [TrackerRecord] = [] {
        didSet {
            filterTrackersForCurrentDate()
        }
    }
    
    private var currentDate: Date = Date()
    private var currentFilter: TrackerFilter = .all
    private var searchText: String = ""
    private let categoryViewModel = CategoryViewModel()
    
    // MARK: - Core Data Stores
    private let trackerStore = TrackerStore()
    private let recordStore = TrackerRecordStore()
    
    // MARK: - UI Components
    private lazy var contentView = UIView()
    private lazy var placeholderStackView = UIStackView()
    private lazy var placeholderImageView = UIImageView()
    private lazy var placeholderLabel = UILabel()
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: TrackersLayoutCalculator.createCollectionViewLayout()
    )
    private lazy var filterButton = UIButton(type: .system)
    private lazy var datePicker = UIDatePicker()
    private lazy var addButton = UIBarButtonItem()
    private lazy var searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Managers
    private lazy var dataSource: TrackersDataSource = {
        let dataSource = TrackersDataSource(
            trackerStore: trackerStore,
            recordStore: recordStore,
            currentDate: currentDate,
            currentFilter: currentFilter
        )
        dataSource.delegate = self
        return dataSource
    }()
    
    private lazy var placeholderManager: TrackersPlaceholderManager = {
        return TrackersPlaceholderManager(
            placeholderStackView: placeholderStackView,
            placeholderImageView: placeholderImageView,
            placeholderLabel: placeholderLabel,
            collectionView: collectionView
        )
    }()
    
    // MARK: - Date Formatter
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCurrentFilter()
        setupUI()
        setupNavigationBar()
        setupCollectionView()
        setupStores()
        setupCategoryViewModel()
        loadData()
        AnalyticsService.shared.report(event: "screen_opened", params: [
            "screen_name": "trackers_main",
            "screen_class": String(describing: type(of: self))
        ])
    }
    
    private func setupDatePickerObserver() {
        // Даем DatePicker полностью настроиться
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Наблюдаем за изменениями в DatePicker
            self.datePicker.addObserver(self, forKeyPath: "date", options: [.new, .old], context: nil)
            
            // Наблюдаем за изменениями текста в UILabel
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.checkDatePickerTextColor()
            }
        }
    }
    
    private func checkDatePickerTextColor() {
        if let label = self.datePicker.subviews.first?
            .subviews.first?
            .subviews.first?
            .subviews[1]
            .subviews.first as? UILabel {
            
            // Если цвет не черный - исправляем и логируем
            if label.textColor != .ypBlackD {
                print("🚨 Цвет изменился: \(label.textColor!) -> черный, текст: '\(label.text ?? "")'")
                label.textColor = .ypBlackD
            }
        }
    }
    
    // KVO для отслеживания изменений даты
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "date" {
            print("📅 Дата изменилась: \(datePicker.date)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.checkDatePickerTextColor()
            }
        }
    }
    
    deinit {
        datePicker.removeObserver(self, forKeyPath: "date")
    }
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .ypWhite
        setupViews()
        setupConstraints()
        setupTapGesture()
    }
    
    // MARK: - Category ViewModel Setup
    private func setupCategoryViewModel() {
        categoryViewModel.categoriesDidUpdate = { [weak self] in
            DispatchQueue.main.async {
                // При изменении категорий перезагружаем трекеры
                self?.categories = self?.trackerStore.fetchCategories() ?? []
                self?.completedTrackers = self?.recordStore.fetchCompletedTrackers() ?? []
                self?.filterTrackersForCurrentDate()
                
                AnalyticsService.shared.report(event: "categories_updated_in_trackers", params: [
                    "screen": "trackers_main"
                ])
            }
        }
    }
    
    private func setupStores() {
        trackerStore.delegate = self
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .ypWhite
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDrag
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        collectionView.showsVerticalScrollIndicator = false
    }
    
    private func setupNavigationBar() {
        title = Constants.navigationTitle
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.ypBlack,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func setupViews() {
        // Content View
        contentView.backgroundColor = .ypWhite
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        
        // Placeholder
        placeholderStackView.axis = .vertical
        placeholderStackView.alignment = .center
        placeholderStackView.spacing = Constants.Layout.placeholderSpacing
        placeholderStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(placeholderStackView)
        
        placeholderImageView.contentMode = .scaleAspectFit
        placeholderImageView.image = R.image.icDizzy()
        placeholderStackView.addArrangedSubview(placeholderImageView)
        
        placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.textAlignment = .center
        placeholderLabel.textColor = .ypBlack
        placeholderLabel.text = Constants.placeholderTitle
        placeholderStackView.addArrangedSubview(placeholderLabel)
        
        // Collection View
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(collectionView)
        
        // Filter Button
        filterButton.setTitle("Фильтры", for: .normal)
        filterButton.backgroundColor = .ypBlue
        filterButton.setTitleColor(.white, for: .normal)
        filterButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        filterButton.layer.cornerRadius = 16
        filterButton.layer.masksToBounds = true
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.addAction(UIAction { [weak self] _ in
            self?.didTapFilterButton()
        }, for: .touchUpInside)
        contentView.addSubview(filterButton)
        
        // Date Picker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale.current
        datePicker.tintColor = .ypBlack
        
        // Устанавливаем только фон (цвет текста теперь делает observer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            // Фон
            self.datePicker.subviews.first?.subviews.first?.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
        }
        
        datePicker.addAction(UIAction { [weak self] _ in
            self?.dateChanged(self?.datePicker)
        }, for: .valueChanged)
        
        // Add Button
        let buttonImage = R.image.plus()
        addButton = UIBarButtonItem(
            image: buttonImage,
            primaryAction: UIAction { [weak self] _ in
                AnalyticsService.shared.report(event: "tracker_creation_opened", params: [
                    "screen": "trackers_main",
                    "source": "plus_button"
                ])
                self?.didTapAddButton()
            }
        )
        addButton.tintColor = .ypBlack
        
        // Search Controller
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = Constants.searchPlaceholder
        searchController.searchBar.delegate = self
        
        setupDatePickerObserver()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Content View
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Collection View
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Placeholder
            placeholderStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: Constants.Layout.placeholderImageSize),
            placeholderImageView.heightAnchor.constraint(equalToConstant: Constants.Layout.placeholderImageSize),
            
            // Date Picker
            datePicker.widthAnchor.constraint(equalToConstant: Constants.Layout.datePickerWidth),
            
            // Filter Button
            filterButton.widthAnchor.constraint(equalToConstant: Constants.Layout.filterButtonWidth),
            filterButton.heightAnchor.constraint(equalToConstant: Constants.Layout.filterButtonHeight),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Layout.filterButtonBottomInset),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Data Management
    private func loadData() {
        categories = trackerStore.fetchCategories()
        completedTrackers = recordStore.fetchCompletedTrackers()
    }
    
    private func filterTrackersForCurrentDate() {
        dataSource.updateData(
            categories: categories,
            completedTrackers: completedTrackers,
            currentDate: currentDate,
            currentFilter: currentFilter,
            searchText: searchText
        )
    }
    
    // MARK: - Filter Management
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
    
    private func updateFilterButtonVisibility() {
        let hasTrackersForCurrentDate = categories.contains { category in
            category.trackers.contains { tracker in
                // Повторяем логику проверки расписания из TrackersDataSource.filterTrackers
                let weekday = Calendar.current.component(.weekday, from: currentDate)
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
                return tracker.scheduleTrackers.isEmpty || tracker.scheduleTrackers.contains(ourWeekday)
            }
        }
        filterButton.isHidden = !hasTrackersForCurrentDate
    }
    
    private func updateFilterButtonAppearance() {
        let isFilterActive = currentFilter == .completed || currentFilter == .uncompleted
        filterButton.setTitleColor(isFilterActive ? .ypRed : .white, for: .normal)
        filterButton.alpha = isFilterActive ? 0.9 : 1.0
    }
    
    private func applyFilter(_ filter: TrackerFilter) {
        switch filter {
        case .today:
            currentFilter = .all
            let today = Date()
            currentDate = today
            datePicker.date = today
            completedTrackers = recordStore.fetchCompletedTrackers()
        case .all, .completed, .uncompleted:
            currentFilter = filter
        }
        
        saveCurrentFilter()
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
    
    private func dateChanged(_ sender: UIDatePicker?) {
        guard let datePicker = sender else { return }
        currentDate = datePicker.date
        
        if currentFilter == .today {
            currentFilter = .all
            saveCurrentFilter()
            updateFilterButtonAppearance()
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.completedTrackers = self.recordStore.fetchCompletedTrackers()
            self.filterTrackersForCurrentDate()
            self.updateFilterButtonVisibility()
        }
    }
    
    private func didTapFilterButton() {
        let filtersVC = TrackerFiltersViewController(selectedFilter: currentFilter)
        filtersVC.onFilterSelected = { [weak self] filter in
            self?.applyFilter(filter)
        }
        let navigationController = UINavigationController(rootViewController: filtersVC)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        AnalyticsService.shared.report(event: "error_occurred", params: [
            "error_message": message,
            "screen": "trackers_main"
        ])
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return TrackersLayoutCalculator.calculateCollectionViewItemSize(for: view)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return TrackersLayoutCalculator.referenceSizeForHeader()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        UIView.animate(withDuration: 0.3) {
            self.filterButton.alpha = offsetY > 100 ? 0.0 : 1.0
        }
    }
}

// MARK: - UISearchResultsUpdating & UISearchBarDelegate
extension TrackersViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        self.searchText = searchText
        
        AnalyticsService.shared.report(event: "search_performed", params: [
            "search_query": searchText,
            "query_length": searchText.count
        ])
        
        filterTrackersForCurrentDate()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchText = ""
        filterTrackersForCurrentDate()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.searchText = ""
            filterTrackersForCurrentDate()
        }
    }
}

// MARK: - TrackersDataSourceDelegate
extension TrackersViewController: TrackersDataSourceDelegate {
    func dataDidUpdate(filteredCategories: [TrackerCategory]) {
        DispatchQueue.main.async {
            self.placeholderManager.updatePlaceholderVisibility(
                filteredCategories: filteredCategories,
                searchText: self.searchText,
                currentFilter: self.currentFilter
            )
            self.updateFilterButtonVisibility()
            self.collectionView.reloadData()
        }
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func didTapPlusButton(in cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let tracker = dataSource.tracker(at: indexPath)
        let trackerId = tracker.idTrackers
        
        let today = Calendar.current.startOfDay(for: Date())
        let selectedDate = Calendar.current.startOfDay(for: currentDate)
        
        guard selectedDate <= today else {
            AnalyticsService.shared.report(event: "tracker_future_date_attempt", params: [
                "tracker_type": tracker.scheduleTrackers.isEmpty ? "event" : "habit",
                "selected_date": dateFormatter.string(from: currentDate)
            ])
            return
        }
        
        do {
            let wasCompleted = recordStore.isTrackerCompleted(trackerId: trackerId, date: currentDate)
            
            if wasCompleted {
                try recordStore.removeRecord(trackerId: trackerId, date: currentDate)
                AnalyticsService.shared.report(event: "tracker_uncompleted", params: [
                    "tracker_type": tracker.scheduleTrackers.isEmpty ? "event" : "habit",
                    "category": tracker.category
                ])
            } else {
                try recordStore.addRecord(trackerId: trackerId, date: currentDate)
                AnalyticsService.shared.report(event: "tracker_completed", params: [
                    "tracker_type": tracker.scheduleTrackers.isEmpty ? "event" : "habit",
                    "category": tracker.category
                ])
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.completedTrackers = self.recordStore.fetchCompletedTrackers()
                
                if self.currentFilter == .completed || self.currentFilter == .uncompleted {
                    self.filterTrackersForCurrentDate()
                } else {
                    self.collectionView.performBatchUpdates {
                        if let cell = self.collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell {
                            let tracker = self.dataSource.tracker(at: indexPath)
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
            AnalyticsService.shared.report(event: "tracker_update_error", params: [
                "error": error.localizedDescription
            ])
            showErrorAlert(message: "Не удалось обновить статус трекера")
        }
    }
    
    func didTogglePin(for trackerId: UUID) {
        do {
            try trackerStore.togglePin(for: trackerId)
            AnalyticsService.shared.report(event: "tracker_pin_toggled", params: [
                "tracker_id": trackerId.uuidString,
                "screen": "trackers_main"
            ])
        } catch {
            showErrorAlert(message: "Не удалось изменить статус закрепления")
        }
    }
    
    func didRequestEdit(for trackerId: UUID) {
        guard let tracker = trackerStore.fetchTracker(by: trackerId) else {
            showErrorAlert(message: "Трекер не найден")
            return
        }
        
        AnalyticsService.shared.report(event: "tracker_edit_requested", params: [
            "tracker_id": trackerId.uuidString,
            "tracker_type": tracker.scheduleTrackers.isEmpty ? "event" : "habit"
        ])
        
        let editVC = CreationTrackerViewController(trackerToEdit: tracker, delegate: self)
        let navigationController = UINavigationController(rootViewController: editVC)
        present(navigationController, animated: true)
    }
    
    func didRequestDelete(for trackerId: UUID) {
        guard let tracker = trackerStore.fetchTracker(by: trackerId) else {
            showErrorAlert(message: "Трекер не найден")
            return
        }
        
        AnalyticsService.shared.report(event: "tracker_delete_requested", params: [
            "tracker_id": trackerId.uuidString,
            "tracker_type": tracker.scheduleTrackers.isEmpty ? "event" : "habit"
        ])
        
        let alert = UIAlertController(
            title: "Уверены что хотите удалить трекер?",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            do {
                try self?.trackerStore.deleteTracker(tracker)
            } catch {
                self?.showErrorAlert(message: "Не удалось удалить трекер")
            }
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - TrackerViewControllerDelegate
extension TrackersViewController: TrackerViewControllerDelegate {
    func didCreateNewTracker(_ tracker: Tracker, categoryTitle: String) {
        dismiss(animated: true)
        let finalCategoryTitle = categoryTitle.isEmpty ? "Мои трекеры" : categoryTitle
        do {
            try trackerStore.createTracker(tracker, categoryTitle: finalCategoryTitle)
        } catch {
            showErrorAlert(message: "Не удалось создать трекер")
        }
    }
    
    func didUpdateTracker(_ tracker: Tracker, categoryTitle: String) {
        dismiss(animated: true)
        do {
            try trackerStore.updateTracker(tracker)
        } catch {
            showErrorAlert(message: "Не удалось обновить трекер")
        }
    }
}

// MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
    func didUpdateTrackers() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.categories = self.trackerStore.fetchCategories()
            self.completedTrackers = self.recordStore.fetchCompletedTrackers()
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
