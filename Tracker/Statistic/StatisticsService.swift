//
//  StatisticsService.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 06.11.2025.
//

import Foundation

final class TrackerStatisticService: StatisticsServiceProtocol {

    func calculateStatistics(trackers: [Tracker], records: [TrackerRecord]) -> TrackerStatistics {
        let best = calculateBestPeriod(from: records)
        let ideal = calculateIdealDays(trackers: trackers, records: records)
        let total = records.count
        let avg = calculateAverageValue(from: records)
        return TrackerStatistics(bestPeriod: best, idealDays: ideal, totalCompleted: total, averageValue: avg)
    }

    // MARK: - Private

    private func calculateBestPeriod(from records: [TrackerRecord]) -> Int {
        guard !records.isEmpty else { return 0 }

        // по каждому трекеру считаем максимальную последовательную серию дней
        let byTracker = Dictionary(grouping: records, by: { $0.trackerId })
        var maxStreak = 0

        for (_, trackerRecords) in byTracker {
            let days = trackerRecords
                .map { Calendar.current.startOfDay(for: $0.date) }
                .sorted()

            guard !days.isEmpty else { continue }

            var current = 1
            var localMax = 1

            for i in 1..<days.count {
                let prev = days[i - 1]
                let curr = days[i]
                if let nextOfPrev = Calendar.current.date(byAdding: .day, value: 1, to: prev),
                   Calendar.current.isDate(nextOfPrev, inSameDayAs: curr) {
                    current += 1
                    localMax = max(localMax, current)
                } else {
                    current = 1
                }
            }

            maxStreak = max(maxStreak, localMax)
        }

        return maxStreak
    }

    private func calculateIdealDays(trackers: [Tracker], records: [TrackerRecord]) -> Int {
        guard !trackers.isEmpty, !records.isEmpty else { return 0 }

        // записи по дням
        let byDay = Dictionary(grouping: records, by: { Calendar.current.startOfDay(for: $0.date) })

        var idealDays = 0

        for (day, dayRecords) in byDay {
            let weekday = Calendar.current.component(.weekday, from: day)
            // Calendar: 1=Sunday ... 7=Saturday -> твой enum Week: 1=Mon ... 7=Sun
            let week: Week = {
                switch weekday {
                case 1: return .sunday
                case 2: return .monday
                case 3: return .tuesday
                case 4: return .wednesday
                case 5: return .thursday
                case 6: return .friday
                case 7: return .saturday
                default: return .monday
                }
            }()

            // все трекеры, запланированные на этот день
            let scheduled = trackers.filter { $0.scheduleTrackers.contains(week) }

            // если на этот день ничего не запланировано — этот день «идеальным» не считаем
            guard !scheduled.isEmpty else { continue }

            let completedIds = Set(dayRecords.map { $0.trackerId })
            let requiredIds  = Set(scheduled.map { $0.idTrackers })

            if requiredIds.isSubset(of: completedIds) {
                idealDays += 1
            }
        }

        return idealDays
    }

    private func calculateAverageValue(from records: [TrackerRecord]) -> Double {
        guard !records.isEmpty else { return 0 }

        let byDay = Dictionary(grouping: records, by: { Calendar.current.startOfDay(for: $0.date) })
        let totalCompletions = records.count
        let daysCount = byDay.keys.count
        return daysCount > 0 ? Double(totalCompletions) / Double(daysCount) : 0
    }
}
