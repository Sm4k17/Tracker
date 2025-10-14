//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 14.10.2025.
//

import CoreData

final class TrackerRecordStore {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    // MARK: - Public Methods
    func fetchCompletedTrackers() -> [TrackerRecord] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        do {
            let recordsCoreData = try context.fetch(request)
            return recordsCoreData.compactMap { recordCoreData -> TrackerRecord? in
                guard let id = recordCoreData.id,
                      let trackerId = recordCoreData.trackerId,
                      let date = recordCoreData.date else {
                    return nil
                }
                
                return TrackerRecord(id: id, trackerId: trackerId, date: date)
            }
        } catch {
            print("❌ Error fetching records: \(error)")
            return []
        }
    }
    
    func addRecord(trackerId: UUID, date: Date) throws {
        let record = TrackerRecordCoreData(context: context)
        record.id = UUID()
        record.trackerId = trackerId
        record.date = date
        
        // Находим трекер и связываем
        let trackerRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        trackerRequest.predicate = NSPredicate(format: "idTrackers == %@", trackerId as CVarArg)
        
        if let tracker = try context.fetch(trackerRequest).first {
            record.tracker = tracker
        }
        
        try context.save()
    }
    
    func removeRecord(trackerId: UUID, date: Date) throws {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "trackerId == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            Calendar.current.startOfDay(for: date) as CVarArg,
            Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: date))! as CVarArg
        )
        
        if let recordToDelete = try context.fetch(request).first {
            context.delete(recordToDelete)
            try context.save()
        }
    }
    
    func isTrackerCompleted(trackerId: UUID, date: Date) -> Bool {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "trackerId == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            Calendar.current.startOfDay(for: date) as CVarArg,
            Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: date))! as CVarArg
        )
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("❌ Error checking completion: \(error)")
            return false
        }
    }
    
    func completedDaysCount(for trackerId: UUID) -> Int {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        
        do {
            return try context.count(for: request)
        } catch {
            print("❌ Error counting records: \(error)")
            return 0
        }
    }
}
