//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 20.10.2025.
//

import Foundation

// MARK: - Category ViewModel
final class CategoryViewModel {
    
    // MARK: - Bindings
    var categoriesDidUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    var onCategoryAdded: ((IndexPath) -> Void)?
    
    // MARK: - Properties
    private let categoryStore = TrackerCategoryStore()
    private(set) var categories: [String] = [] {
        didSet {
            categoriesDidUpdate?()
        }
    }
    
    var isEmpty: Bool {
        return categories.isEmpty
    }
    
    // MARK: - Public Methods
    func loadCategories() {
        categories = categoryStore.fetchCategoryTitles()
    }
    
    // MARK: - Public Methods
    func createCategory(title: String) {
        do {
            try categoryStore.createCategory(title: title)
            
            // Сначала обновляем массив категорий
            let updatedCategories = categoryStore.fetchCategoryTitles()
            
            // Находим индекс новой категории
            if let newIndex = updatedCategories.firstIndex(of: title) {
                categories = updatedCategories
                let newIndexPath = IndexPath(row: newIndex, section: 0)
                onCategoryAdded?(newIndexPath)
            } else {
                // Если не нашли - просто обновляем все
                categories = updatedCategories
                categoriesDidUpdate?()
            }
        } catch {
            onError?("Ошибка создания категории: \(error.localizedDescription)")
        }
    }
    
    func selectCategory(at index: Int) -> String {
        return categories[index]
    }
    
    func isCategorySelected(_ category: String, comparedTo selectedCategory: String) -> Bool {
        return category == selectedCategory
    }
}
