//
//  CoreDataManager.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 14.10.2025.
//

import CoreData
import UIKit

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        
        // ОДНО хранилище - ПРОСТО и РАБОЧЕ
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
    
    private func storeURL(for storeName: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("\(storeName).sqlite")
    }
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
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

// Сброс базы
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
