//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 30.09.2025.
//

import Foundation

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

// MARK: - Hashable
extension TrackerRecord: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(date)
    }
        
    static func == (lhs: TrackerRecord, rhs: TrackerRecord) -> Bool {
        lhs.id == rhs.id && Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
    }
}
