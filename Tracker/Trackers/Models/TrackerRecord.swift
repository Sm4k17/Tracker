//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 30.09.2025.
//

import Foundation

/// Модель записи о выполнении трекера
/// Фиксирует факт выполнения трекера в определенную дату
struct TrackerRecord {
    let id: UUID
    let trackerId: UUID
    let date: Date
    
    init(id: UUID = UUID(), trackerId: UUID, date: Date) {
        self.id = id
        self.trackerId = trackerId
        self.date = date
    }
}

/*
 TrackerRecord - модель статистики

Назначение: Фиксация фактов выполнения
Использование: Подсчет дней, проверка выполнения на дату
*/
