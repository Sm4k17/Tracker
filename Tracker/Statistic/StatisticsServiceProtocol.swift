//
//  StatisticsServiceProtocol.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 06.11.2025.
//

protocol StatisticsServiceProtocol {
    func calculateStatistics(trackers: [Tracker], records: [TrackerRecord]) -> TrackerStatistics
}
