//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 14.10.2025.
//

import CoreData

// MARK: - Constants
private enum CoreDataKeys {
    static let title = "title"
}

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Properties
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Setup
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: CoreDataKeys.title, ascending: true)
        ]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("❌ Error fetching categories: \(error)")
        }
    }
    
    // MARK: - Public Methods
    func fetchAllCategories() -> [TrackerCategory] {
        guard let categoriesCoreData = fetchedResultsController.fetchedObjects else { return [] }
        
        return categoriesCoreData.compactMap { categoryCoreData -> TrackerCategory? in
            guard let title = categoryCoreData.title else { return nil }
            
            let trackersSet = categoryCoreData.trackers as? Set<TrackerCoreData> ?? Set()
            let trackers = trackersSet.compactMap { trackerCoreData -> Tracker? in
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
                    category: title
                )
            }
            
            return TrackerCategory(title: title, trackers: trackers)
        }
    }
    
    func fetchCategoryTitles() -> [String] {
        guard let categoriesCoreData = fetchedResultsController.fetchedObjects else { return [] }
        return categoriesCoreData.compactMap { $0.title }
    }
    
    func createCategory(title: String) throws {
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        
        try context.save()
    }
    
    func deleteCategory(title: String) throws {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "\(CoreDataKeys.title) == %@", title)
        
        if let categoryToDelete = try context.fetch(request).first {
            context.delete(categoryToDelete)
            try context.save()
        }
    }
    
    func fetchOrCreateCategory(title: String) -> TrackerCategoryCoreData {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "\(CoreDataKeys.title) == %@", title)
        
        if let existingCategory = try? context.fetch(request).first {
            return existingCategory
        }
        
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = title
        return newCategory
    }
    
    func isCategoryEmpty(title: String) -> Bool {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "\(CoreDataKeys.title) == %@", title)
        
        guard let category = try? context.fetch(request).first else { return true }
        return (category.trackers?.count ?? 0) == 0
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategories()
    }
}
