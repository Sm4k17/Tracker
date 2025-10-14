//
//  TrackerStore.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 14.10.2025.
//

import CoreData
import UIKit

final class TrackerStore: NSObject {
    
    weak var delegate: TrackerStoreDelegate?
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    private let categoryStore = TrackerCategoryStore()
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "trackerCategory.title", ascending: true),
            NSSortDescriptor(key: "nameTrackers", ascending: true)
        ]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: "trackerCategory.title",
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("❌ Error fetching trackers: \(error)")
        }
    }
    
    // MARK: - Public Methods
    func fetchCategories() -> [TrackerCategory] {
        guard let sections = fetchedResultsController.sections else { return [] }
        
        return sections.compactMap { section in
            guard let trackersCoreData = section.objects as? [TrackerCoreData] else { return nil }
            
            let trackers = trackersCoreData.compactMap { trackerCoreData -> Tracker? in
                guard let id = trackerCoreData.idTrackers,
                      let name = trackerCoreData.nameTrackers,
                      let emoji = trackerCoreData.emojiTrackers,
                      let color = trackerCoreData.getColor() else {
                    return nil
                }
                
                let schedule = trackerCoreData.getSchedule()
                
                return Tracker(
                    idTrackers: id,
                    name: name,
                    color: color,
                    emoji: emoji,
                    scheduleTrackers: schedule,
                    category: trackerCoreData.categoryTitle ?? ""
                )
            }
            
            return TrackerCategory(title: section.name, trackers: trackers)
        }
    }
    
    func createTracker(_ tracker: Tracker, categoryTitle: String) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.idTrackers = tracker.idTrackers
        trackerCoreData.nameTrackers = tracker.name
        trackerCoreData.emojiTrackers = tracker.emoji
        trackerCoreData.categoryTitle = categoryTitle
        trackerCoreData.isPinned = false
        trackerCoreData.isRegular = !tracker.scheduleTrackers.isEmpty
        trackerCoreData.createdAt = Date()
        
        trackerCoreData.setColor(tracker.color)
        trackerCoreData.setSchedule(tracker.scheduleTrackers)
        
        // Используем CategoryStore для работы с категориями
        let category = categoryStore.fetchOrCreateCategory(title: categoryTitle)
        trackerCoreData.trackerCategory = category
        
        try context.save()
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "idTrackers == %@", tracker.idTrackers as CVarArg)
        
        if let trackerToDelete = try context.fetch(request).first {
            context.delete(trackerToDelete)
            try context.save()
        }
    }
    
    func fetchTracker(by id: UUID) -> Tracker? {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "idTrackers == %@", id as CVarArg)
        
        guard let trackerCoreData = try? context.fetch(request).first,
              let trackerId = trackerCoreData.idTrackers,
              let name = trackerCoreData.nameTrackers,
              let emoji = trackerCoreData.emojiTrackers,
              let color = trackerCoreData.getColor() else {
            return nil
        }
        
        let schedule = trackerCoreData.getSchedule()
        
        return Tracker(
            idTrackers: trackerId,
            name: name,
            color: color,
            emoji: emoji,
            scheduleTrackers: schedule,
            category: trackerCoreData.categoryTitle ?? ""
        )
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateTrackers()
    }
}
