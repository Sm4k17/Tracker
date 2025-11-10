//
//  Tracker.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 30.09.2025.
//

import UIKit

/// Модель трекера - основная сущность приложения
/// Представляет собой привычку или нерегулярное событие для отслеживания
struct Tracker {
    let idTrackers: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let scheduleTrackers: Set<Week>
    let category: String
    var isPinned: Bool = false
}

// Для удобства создания
extension Tracker {
    init(name: String, color: UIColor, emoji: String, schedule: Set<Week>, category: String = "") {
        self.idTrackers = UUID()
        self.name = name
        self.color = color
        self.emoji = emoji
        self.scheduleTrackers = schedule
        self.category = category
        self.isPinned = false
    }
}

/*
 Tracker - основная бизнес-модель
 
 Назначение: Хранит все данные о трекере
 Использование: Создание, отображение, фильтрация трекеров
 Ключевые поля: расписание, цвет, emoji, категория
 */
