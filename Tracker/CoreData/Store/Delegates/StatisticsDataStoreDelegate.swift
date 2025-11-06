//
//  StatisticsDataStoreDelegate.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 06.11.2025.
//

import Foundation

protocol StatisticsDataStoreDelegate: AnyObject {
    func statisticsDataStore(_ store: StatisticsDataStore, didUpdate statistics: TrackerStatistics?)
}
