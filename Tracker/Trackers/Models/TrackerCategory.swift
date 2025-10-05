//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 30.09.2025.
//

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
    
    // Для обратной совместимости
    var header: String { title }
}

// Для удобства создания
extension TrackerCategory {
    init(header: String, trackers: [Tracker]) {
        self.title = header
        self.trackers = trackers
    }
}
