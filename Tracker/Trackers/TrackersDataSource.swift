//
//  TrackersDataSource.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 03.11.2025.
//

import UIKit

final class TrackersDataSource: NSObject {
    
    // MARK: - Properties
    weak var delegate: TrackersDataSourceDelegate?
    private var filteredCategories: [TrackerCategory] = []
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    private var currentDate: Date
    private var currentFilter: TrackerFilter
    private var searchText: String = ""
    
    // MARK: - Initialization
    init(
        trackerStore: TrackerStore,
        recordStore: TrackerRecordStore,
        currentDate: Date = Date(),
        currentFilter: TrackerFilter = .all
    ) {
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        self.currentDate = currentDate
        self.currentFilter = currentFilter
        super.init()
    }
    
    // MARK: - Public Methods
    func updateData(
        categories: [TrackerCategory],
        completedTrackers: [TrackerRecord],
        currentDate: Date? = nil,
        currentFilter: TrackerFilter? = nil,
        searchText: String? = nil
    ) {
        if let currentDate = currentDate {
            self.currentDate = currentDate
        }
        if let currentFilter = currentFilter {
            self.currentFilter = currentFilter
        }
        if let searchText = searchText {
            self.searchText = searchText
        }
        
        filterTrackers(categories: categories, completedTrackers: completedTrackers)
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker {
        return filteredCategories[indexPath.section].trackers[indexPath.row]
    }
    
    func categoryTitle(at section: Int) -> String {
        return filteredCategories[section].title
    }
    
    func isTrackerCompletedToday(id: UUID) -> Bool {
        return recordStore.isTrackerCompleted(trackerId: id, date: currentDate)
    }
    
    func completedDaysCount(for trackerId: UUID) -> Int {
        return recordStore.completedDaysCount(for: trackerId)
    }
    
    // MARK: - Private Methods
    private func filterTrackers(categories: [TrackerCategory], completedTrackers: [TrackerRecord]) {
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
        
        let newFilteredCategories = TrackerFilterService.filterTrackers(
            categories: categories,
            currentFilter: currentFilter,
            completedTrackers: completedTrackers,
            currentDate: currentDate,
            searchText: searchText,
            weekday: ourWeekday
        )
        
        filteredCategories = organizeCategoriesWithPinnedTrackers(newFilteredCategories)
        delegate?.dataDidUpdate(filteredCategories: filteredCategories)
    }
    
    private func organizeCategoriesWithPinnedTrackers(_ categories: [TrackerCategory]) -> [TrackerCategory] {
        var pinnedTrackers: [Tracker] = []
        var regularCategories: [TrackerCategory] = []
        
        for category in categories {
            var pinnedInCategory: [Tracker] = []
            var regularInCategory: [Tracker] = []
            
            for tracker in category.trackers {
                if tracker.isPinned {
                    pinnedInCategory.append(tracker)
                } else {
                    regularInCategory.append(tracker)
                }
            }
            
            pinnedTrackers.append(contentsOf: pinnedInCategory)
            
            if !regularInCategory.isEmpty {
                let regularCategory = TrackerCategory(title: category.title, trackers: regularInCategory)
                regularCategories.append(regularCategory)
            }
        }
        
        var resultCategories: [TrackerCategory] = []
        
        if !pinnedTrackers.isEmpty {
            let pinnedCategory = TrackerCategory(title: "Закрепленные", trackers: pinnedTrackers)
            resultCategories.append(pinnedCategory)
        }
        
        resultCategories.append(contentsOf: regularCategories)
        return resultCategories
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersDataSource: UICollectionViewDataSource {
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
        
        cell.configure(with: viewModel, animated: false)
        if let trackerCellDelegate = delegate as? TrackerCellDelegate {
            cell.delegate = trackerCellDelegate
        }
        
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

// MARK: - Delegate Protocol
protocol TrackersDataSourceDelegate: AnyObject {
    func dataDidUpdate(filteredCategories: [TrackerCategory])
}
