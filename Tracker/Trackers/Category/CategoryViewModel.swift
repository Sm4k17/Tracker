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
    
    // MARK: - Context Menu Methods
    func updateCategory(from oldName: String, to newName: String) {
        do {
            // Проверяем, что новое название уникально (если оно изменилось)
            if oldName != newName && !categoryStore.isCategoryNameUnique(newName) {
                // Откладываем показ ошибки, чтобы модальное окно успело закрыться
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.onError?("Категория с названием '\(newName)' уже существует")
                }
                return
            }
            
            try categoryStore.updateCategory(from: oldName, to: newName)
            // Делегат автоматически вызовет обновление через controllerDidChangeContent
            
            AnalyticsService.shared.report(event: "category_edited", params: [
                "old_name": oldName,
                "new_name": newName
            ])
        } catch {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.onError?("Ошибка редактирования категории: \(error.localizedDescription)")
            }
        }
    }
    
    func createCategory(title: String) {
        do {
            // Проверяем уникальность названия
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
            // УДАЛЯЕМ ПРОВЕРКУ НА ПУСТОТУ - удаляем категорию даже если в ней есть трекеры
            try categoryStore.deleteCategory(title: category)
            // Делегат автоматически вызовет обновление через controllerDidChangeContent
            
            AnalyticsService.shared.report(event: "category_deleted", params: [
                "category_name": category
            ])
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
