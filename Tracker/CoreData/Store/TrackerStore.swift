//
//  TrackerStore.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 14.10.2025.
//

import CoreData

// MARK: - Constants
private enum CoreDataKeys {
    static let idTrackers = "idTrackers"
    static let nameTrackers = "nameTrackers"
    static let trackerCategoryTitle = "trackerCategory.title"
    static let isPinned = "isPinned"
    static let createdAt = "createdAt"
}

final class TrackerStore: NSObject {
    
    // MARK: - Properties
    weak var delegate: TrackerStoreDelegate?
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    private let categoryStore = TrackerCategoryStore()
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
        super.init()
        setupFetchedResultsController()
        setupCategoryStoreDelegate()
    }
    
    // MARK: - Category Store Delegate
    private func setupCategoryStoreDelegate() {
        categoryStore.delegate = self
    }
    
    // MARK: - Setup
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        // Сначала закрепленные, потом по дате создания
        request.sortDescriptors = [
            NSSortDescriptor(key: CoreDataKeys.isPinned, ascending: false),
            NSSortDescriptor(key: CoreDataKeys.trackerCategoryTitle, ascending: true),
            NSSortDescriptor(key: CoreDataKeys.nameTrackers, ascending: true),
            NSSortDescriptor(key: CoreDataKeys.createdAt, ascending: true)
        ]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: CoreDataKeys.trackerCategoryTitle,
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
                    category: trackerCoreData.categoryTitle ?? "",
                    isPinned: trackerCoreData.isPinned
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
        trackerCoreData.isPinned = tracker.isPinned
        trackerCoreData.isRegular = !tracker.scheduleTrackers.isEmpty
        trackerCoreData.createdAt = Date()
        
        trackerCoreData.setColor(tracker.color)
        trackerCoreData.setSchedule(tracker.scheduleTrackers)
        
        let category = categoryStore.fetchOrCreateCategory(title: categoryTitle)
        trackerCoreData.trackerCategory = category
        
        try context.save()
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "\(CoreDataKeys.idTrackers) == %@",
            tracker.idTrackers as CVarArg
        )
        
        if let trackerToDelete = try context.fetch(request).first {
            context.delete(trackerToDelete)
            try context.save()
        }
    }
    
    func fetchTracker(by id: UUID) -> Tracker? {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "\(CoreDataKeys.idTrackers) == %@",
            id as CVarArg
        )
        
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
            category: trackerCoreData.categoryTitle ?? "",
            isPinned: trackerCoreData.isPinned
        )
    }
    
    // MARK: - Pin Methods
    func updateTrackersCategory(from oldCategory: String, to newCategory: String) throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "categoryTitle == %@", oldCategory)
        
        let trackersToUpdate = try context.fetch(request)
        for tracker in trackersToUpdate {
            tracker.categoryTitle = newCategory
        }
    }
    
    func togglePin(for trackerId: UUID) throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "idTrackers == %@",
            trackerId as CVarArg
        )
        
        if let trackerCoreData = try context.fetch(request).first {
            trackerCoreData.isPinned.toggle()
            try context.save()
        }
    }
    
    func fetchPinnedTrackers() -> [Tracker] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "\(CoreDataKeys.isPinned) == true")
        
        do {
            let pinnedTrackersCoreData = try context.fetch(request)
            return pinnedTrackersCoreData.compactMap { trackerCoreData -> Tracker? in
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
                    category: trackerCoreData.categoryTitle ?? "",
                    isPinned: trackerCoreData.isPinned
                )
            }
        } catch {
            print("❌ Error fetching pinned trackers: \(error)")
            return []
        }
    }
    
    func updateTracker(_ tracker: Tracker) throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "idTrackers == %@",
            tracker.idTrackers as CVarArg
        )
        
        if let trackerCoreData = try context.fetch(request).first {
            trackerCoreData.nameTrackers = tracker.name
            trackerCoreData.emojiTrackers = tracker.emoji
            trackerCoreData.categoryTitle = tracker.category
            trackerCoreData.isPinned = tracker.isPinned
            
            trackerCoreData.setColor(tracker.color)
            trackerCoreData.setSchedule(tracker.scheduleTrackers)
            
            // Обновляем категорию если изменилась
            if let currentCategory = trackerCoreData.trackerCategory,
               currentCategory.title != tracker.category {
                let newCategory = categoryStore.fetchOrCreateCategory(title: tracker.category)
                trackerCoreData.trackerCategory = newCategory
            }
            
            try context.save()
        }
    }
    
    // MARK: - Search Methods
    func searchTrackers(with query: String) -> [Tracker] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        if !query.isEmpty {
            request.predicate = NSPredicate(
                format: "\(CoreDataKeys.nameTrackers) CONTAINS[cd] %@",
                query
            )
        }
        
        request.sortDescriptors = [
            NSSortDescriptor(key: CoreDataKeys.isPinned, ascending: false),
            NSSortDescriptor(key: CoreDataKeys.nameTrackers, ascending: true)
        ]
        
        do {
            let trackersCoreData = try context.fetch(request)
            return trackersCoreData.compactMap { trackerCoreData -> Tracker? in
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
                    category: trackerCoreData.categoryTitle ?? "",
                    isPinned: trackerCoreData.isPinned
                )
            }
        } catch {
            print("❌ Error searching trackers: \(error)")
            return []
        }
    }
    
    // MARK: - Statistics
    func getTotalTrackersCount() -> Int {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        do {
            return try context.count(for: request)
        } catch {
            print("❌ Error counting trackers: \(error)")
            return 0
        }
    }
    
    func getPinnedTrackersCount() -> Int {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "\(CoreDataKeys.isPinned) == true")
        
        do {
            return try context.count(for: request)
        } catch {
            print("❌ Error counting pinned trackers: \(error)")
            return 0
        }
    }
    
    func getTrackersCountInCategory(_ categoryTitle: String) -> Int {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "\(CoreDataKeys.trackerCategoryTitle) == %@",
            categoryTitle
        )
        
        do {
            return try context.count(for: request)
        } catch {
            print("❌ Error counting trackers in category: \(error)")
            return 0
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateTrackers()
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension TrackerStore: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        // При изменении категорий принудительно перезагружаем FRC
        do {
            try fetchedResultsController.performFetch()
            delegate?.didUpdateTrackers()
        } catch {
            print("❌ Error reloading trackers after category update: \(error)")
        }
    }
}

// MARK: - Batch Operations
extension TrackerStore {
    func deleteAllTrackers() throws {
        let request: NSFetchRequest<NSFetchRequestResult> = TrackerCoreData.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("❌ Error deleting all trackers: \(error)")
            throw error
        }
    }
    
    func unpinAllTrackers() throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "\(CoreDataKeys.isPinned) == true")
        
        do {
            let pinnedTrackers = try context.fetch(request)
            for tracker in pinnedTrackers {
                tracker.isPinned = false
            }
            try context.save()
        } catch {
            print("❌ Error unpinning all trackers: \(error)")
            throw error
        }
    }
}
