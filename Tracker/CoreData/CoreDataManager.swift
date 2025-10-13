//
//  CoreDataManager.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 14.10.2025.
//

import CoreData
import UIKit

/// Менеджер для работы с Core Data
final class CoreDataManager {
    
    // MARK: - Singleton
    static let shared = CoreDataManager()
    
    private init() {}
    
    // MARK: - Core Data stack
    
    /// Persistent Container - главный компонент Core Data
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            } else {
                print("✅ Core Data stack initialized successfully")
                print("📁 Database location: \(storeDescription.url?.absoluteString ?? "unknown")")
            }
        }
        
        // Автоматически сливаем изменения из контекста
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    // MARK: - Core Data context
    
    /// Основной контекст для работы с данными (главный поток)
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    /// Фоновый контекст для тяжелых операций
    var backgroundContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    // MARK: - Core Data saving support
    
    /// Сохранение контекста с обработкой ошибок
    func saveContext() {
        let context = persistentContainer.viewContext
        
        guard context.hasChanges else {
            print("ℹ️ No changes to save")
            return
        }
        
        do {
            try context.save()
            print("✅ Changes saved successfully")
        } catch {
            let nserror = error as NSError
            context.rollback()
            print("❌ Error saving context: \(nserror), \(nserror.userInfo)")
        }
    }
    
    /// Асинхронное сохранение фонового контекста
    func saveBackgroundContext(_ context: NSManagedObjectContext, completion: @escaping (Result<Void, Error>) -> Void) {
        context.perform {
            do {
                try context.save()
                completion(.success(()))
                print("✅ Background context saved successfully")
            } catch {
                context.rollback()
                completion(.failure(error))
                print("❌ Error saving background context: \(error)")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Сброс всей базы данных (для отладки)
    func resetDatabase() {
        let storeContainer = persistentContainer.persistentStoreCoordinator
        
        do {
            for store in storeContainer.persistentStores {
                try storeContainer.destroyPersistentStore(
                    at: store.url!,
                    ofType: store.type,
                    options: nil
                )
            }
        } catch {
            print("❌ Error resetting database: \(error)")
        }
        
        // Пересоздаем stores
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("❌ Error reloading stores: \(error)")
            } else {
                print("✅ Database reset successfully")
            }
        }
    }
    
    /// Проверка существования объекта по предикату
    func objectExists<T: NSManagedObject>(_ objectType: T.Type, predicate: NSPredicate) -> Bool {
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<T>(entityName: String(describing: objectType))
        request.predicate = predicate
        request.fetchLimit = 1
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("❌ Error checking object existence: \(error)")
            return false
        }
    }
    
    /// Получение количества объектов
    func count<T: NSManagedObject>(_ objectType: T.Type, predicate: NSPredicate? = nil) -> Int {
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<T>(entityName: String(describing: objectType))
        request.predicate = predicate
        
        do {
            return try context.count(for: request)
        } catch {
            print("❌ Error counting objects: \(error)")
            return 0
        }
    }
}

// MARK: - Extension for UIColor transformation
extension TrackerCoreData {
    
    /// Преобразование UIColor в Data для сохранения
    func setColor(_ color: UIColor) {
        do {
            self.colorTrackers = try NSKeyedArchiver.archivedData(
                withRootObject: color,
                requiringSecureCoding: false
            )
        } catch {
            print("❌ Error archiving color: \(error)")
        }
    }
    
    /// Преобразование Data обратно в UIColor
    func getColor() -> UIColor? {
        guard let data = colorTrackers else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
    }
    
    /// Преобразование Set<Week> в Data для сохранения
    func setSchedule(_ schedule: Set<Week>) {
        let weekNumbers = schedule.map { $0.rawValue }
        do {
            self.scheduleTrackers = try JSONEncoder().encode(weekNumbers)
        } catch {
            print("❌ Error encoding schedule: \(error)")
        }
    }
    
    /// Преобразование Data обратно в Set<Week>
    func getSchedule() -> Set<Week> {
        guard let data = scheduleTrackers,
              let weekNumbers = try? JSONDecoder().decode([Int].self, from: data) else {
            return []
        }
        return Set(weekNumbers.compactMap { Week(rawValue: $0) })
    }
}

// MARK: - Quick Access Methods
extension CoreDataManager {
    
    /// Быстрый доступ к контексту (удобно для использования в коде)
    static var context: NSManagedObjectContext {
        return shared.context
    }
    
    /// Быстрое сохранение (удобно для использования в коде)
    static func save() {
        shared.saveContext()
    }
}
