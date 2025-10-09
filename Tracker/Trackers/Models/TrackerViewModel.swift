//
//  TrackerViewModel.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 30.09.2025.
//

import Foundation

/// ViewModel для отображения трекера в ячейке коллекции
/// Содержит данные трекера + информацию о его выполнении
struct TrackerViewModel {
    let tracker: Tracker
    let isCompletedToday: Bool
    let completedDays: Int
    let currentDate: Date
    
    var isFutureDate: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let selectedDate = Calendar.current.startOfDay(for: currentDate)
        return selectedDate > today
    }
}

/*
 TrackerViewModel - модель для UI

 Назначение: Подготовка данных для отображения
 Использование: Заполнение ячеек коллекции
 */
