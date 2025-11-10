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
        case .monday: return R.string.localizable.monday()
        case .tuesday: return R.string.localizable.tuesday()
        case .wednesday: return R.string.localizable.wednesday()
        case .thursday: return R.string.localizable.thursday()
        case .friday: return R.string.localizable.friday()
        case .saturday: return R.string.localizable.saturday()
        case .sunday: return R.string.localizable.sunday()
        }
    }
    
    var localizedShortTitle: String {
        switch self {
        case .monday: return R.string.localizable.mon()
        case .tuesday: return R.string.localizable.tue()
        case .wednesday: return R.string.localizable.wed()
        case .thursday: return R.string.localizable.thu()
        case .friday: return R.string.localizable.fri()
        case .saturday: return R.string.localizable.sat()
        case .sunday: return R.string.localizable.sun()
        }
    }
}

/*
 Week - модель расписания
 
 Назначение: Определение дней показа трекера
 Использование: Фильтрация по дате, настройка расписания
 */
