//
//  TrackerFilterService.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 03.11.2025.
//

import Foundation

final class TrackerFilterService {
    
    static func filterTrackers(
        categories: [TrackerCategory],
        currentFilter: TrackerFilter,
        completedTrackers: [TrackerRecord],
        currentDate: Date,
        searchText: String = "",
        weekday: Week
    ) -> [TrackerCategory] {
        
        return categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                // Фильтрация по расписанию
                let matchesSchedule = tracker.scheduleTrackers.isEmpty ||
                tracker.scheduleTrackers.contains(weekday)
                
                // Фильтрация по поиску
                let matchesSearch = searchText.isEmpty ||
                tracker.name.lowercased().contains(searchText.lowercased())
                
                // Фильтрация по выбранному фильтру
                let matchesFilter: Bool
                switch currentFilter {
                case .completed:
                    // Показываем только завершённые трекеры на выбранную дату
                    matchesFilter = completedTrackers.contains {
                        $0.trackerId == tracker.idTrackers &&
                        Calendar.current.isDate($0.date, inSameDayAs: currentDate)
                    }
                case .uncompleted:
                    // Показываем только незавершённые трекеры на выбранную дату
                    matchesFilter = !completedTrackers.contains {
                        $0.trackerId == tracker.idTrackers &&
                        Calendar.current.isDate($0.date, inSameDayAs: currentDate)
                    }
                case .today:
                    // Дата уже установлена на сегодня в TrackersViewController
                    matchesFilter = true
                case .all:
                    // Показываем все трекеры на выбранную дату
                    matchesFilter = true
                }
                
                return matchesSchedule && matchesSearch && matchesFilter
            }
            
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
    }
}
