//
//  StatisticsDataStore.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 06.11.2025.
//

import Foundation

final class StatisticsDataStore {

    private enum Constants {
        static let minRecordsForStatistics = 1
    }

    weak var delegate: StatisticsDataStoreDelegate?

    private let recordStore: TrackerRecordStore
    private let trackerStore: TrackerStore
    private let statisticsService: StatisticsServiceProtocol

    init(
        recordStore: TrackerRecordStore = TrackerRecordStore(),
        trackerStore: TrackerStore = TrackerStore(),
        statisticsService: StatisticsServiceProtocol = TrackerStatisticService()
    ) {
        self.recordStore = recordStore
        self.trackerStore = trackerStore
        self.statisticsService = statisticsService
    }

    func refresh() {
        reloadStatistics()
    }

    // MARK: - Private

    private func reloadStatistics() {
        let records = recordStore.fetchCompletedTrackers()
        // Берём трекеры из готового TrackerStore через категории 
        let trackers = trackerStore.fetchCategories().flatMap { $0.trackers }

        guard records.count >= Constants.minRecordsForStatistics else {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.statisticsDataStore(self, didUpdate: nil)
            }
            return
        }

        let statistics = statisticsService.calculateStatistics(trackers: trackers, records: records)

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.delegate?.statisticsDataStore(self, didUpdate: statistics)
        }
    }
}
