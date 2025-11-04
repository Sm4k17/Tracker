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
    
    // MARK: - Properties
    private let categoryStore = TrackerCategoryStore()
    private(set) var categories: [String] = []
    
    var isEmpty: Bool {
        return categories.isEmpty
    }
    
    // MARK: - Initialization
    init() {
        categoryStore.delegate = self
        loadCategories()
    }
    
    // MARK: - Public Methods
    func loadCategories() {
        categories = categoryStore.fetchCategoryTitles()
        categoriesDidUpdate?()
    }
    
    func updateCategory(from oldName: String, to newName: String) {
        do {
            if oldName != newName && !categoryStore.isCategoryNameUnique(newName) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.onError?("Категория с названием '\(newName)' уже существует")
                }
                return
            }
            
            try categoryStore.updateCategory(from: oldName, to: newName)
            // Делегат автоматически вызовет обновление через controllerDidChangeContent
            
        } catch {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.onError?("Ошибка редактирования категории: \(error.localizedDescription)")
            }
        }
    }
    
    func createCategory(title: String) {
        do {
            guard categoryStore.isCategoryNameUnique(title) else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.onError?("Категория с таким названием уже существует")
                }
                return
            }
            
            try categoryStore.createCategory(title: title)
            // Делегат автоматически вызовет обновление через controllerDidChangeContent
        } catch {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.onError?("Ошибка создания категории: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteCategory(_ category: String) {
        do {
            try categoryStore.deleteCategory(title: category)
            // Делегат автоматически вызовет обновление через controllerDidChangeContent
        } catch {
            onError?("Ошибка удаления категории: \(error.localizedDescription)")
        }
    }
    
    func selectCategory(at index: Int) -> String {
        return categories[index]
    }
    
    func isCategorySelected(_ category: String, comparedTo selectedCategory: String) -> Bool {
        return category == selectedCategory
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        // Полностью перезагружаем категории при любых изменениях в store
        let updatedCategories = categoryStore.fetchCategoryTitles()
        categories = updatedCategories
        categoriesDidUpdate?()
    }
}
