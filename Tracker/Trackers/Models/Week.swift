//
//  Week.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 30.09.2025.
//

/// Перечисление дней недели
/// Используется для задания расписания показа трекеров
enum Week: Int, CaseIterable {
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case sunday = 7
    
    var localizedTitle: String {
        switch self {
        case .monday: return "monday".localized
        case .tuesday: return "tuesday".localized
        case .wednesday: return "wednesday".localized
        case .thursday: return "thursday".localized
        case .friday: return "friday".localized
        case .saturday: return "saturday".localized
        case .sunday: return "sunday".localized
        }
    }
    
    var localizedShortTitle: String {
        switch self {
        case .monday: return "mon".localized
        case .tuesday: return "tue".localized
        case .wednesday: return "wed".localized
        case .thursday: return "thu".localized
        case .friday: return "fri".localized
        case .saturday: return "sat".localized
        case .sunday: return "sun".localized
        }
    }
}

/*
 Week - модель расписания
 
 Назначение: Определение дней показа трекера
 Использование: Фильтрация по дате, настройка расписания
 */
