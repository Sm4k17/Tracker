//
//  Tracker.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 30.09.2025.
//

import UIKit

struct Tracker {
    let idTrackers: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let scheduleTrackers: Set<Week>
    let category: String
    
    // Для обратной совместимости
    var id: UUID { idTrackers }
    var schedule: Set<Week> { scheduleTrackers }
}

// Для удобства создания
extension Tracker {
    init(id: UUID = UUID(), name: String, color: UIColor, emoji: String, schedule: Set<Week>, category: String = "") {
        self.idTrackers = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.scheduleTrackers = schedule
        self.category = category
    }
}
