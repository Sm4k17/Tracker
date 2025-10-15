//
//  CoreDataManager.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 14.10.2025.
//

import CoreData

final class CoreDataManager {
    
    // MARK: - Properties
    static let shared = CoreDataManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        
        let storeDescription = NSPersistentStoreDescription()
        storeDescription.url = storeURL(for: "TrackerData")
        
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores { _, error in
            if let error = error {
                print("❌ Failed to load store: \(error)")
            } else {
                print("✅ Store loaded successfully")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Public Methods
    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("❌ Error saving: \(error)")
            context.rollback()
        }
    }
}

// MARK: - Private Methods
private extension CoreDataManager {
    func storeURL(for storeName: String) -> URL {
        guard let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            print("⚠️ Using temporary directory as fallback")
            return FileManager.default.temporaryDirectory.appendingPathComponent("\(storeName).sqlite")
        }
        
        return documentsDirectory.appendingPathComponent("\(storeName).sqlite")
    }
}

// MARK: - Database Reset
extension CoreDataManager {
    static func resetDatabase() {
        let storeURL = shared.storeURL(for: "TrackerData")
        let walURL = storeURL.deletingPathExtension().appendingPathExtension("sqlite-wal")
        let shmURL = storeURL.deletingPathExtension().appendingPathExtension("sqlite-shm")
        
        for url in [storeURL, walURL, shmURL] {
            if FileManager.default.fileExists(atPath: url.path) {
                try? FileManager.default.removeItem(at: url)
            }
        }
        
        _ = shared.persistentContainer
        print("🔥 Database reset complete")
    }
}
