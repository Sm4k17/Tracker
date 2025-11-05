//
//  TrackerFiltersViewController.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 03.11.2025.
//

import UIKit

final class TrackerFiltersViewController: UIViewController {
    
    // MARK: - Public variables
    var onFilterSelected: ((TrackerFilter) -> Void)?
    
    // MARK: - Private variables
    private let filterOptions = ["Все трекеры", "Трекеры на сегодня", "Завершенные", "Не завершенные"]
    private var initiallySelectedFilter: TrackerFilter
    private var selectedFilter: TrackerFilter
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        return tableView
    }()
    
    // MARK: - init
    init(selectedFilter: TrackerFilter = .all) {
        self.initiallySelectedFilter = selectedFilter
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Аналитика: открытие экрана фильтров
        AnalyticsService.shared.report(event: "open", params: [
            "screen": "Filters"
        ])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            // Аналитика: закрытие экрана фильтров
            AnalyticsService.shared.report(event: "close", params: [
                "screen": "Filters"
            ])
        }
    }
    
    private func setupUI() {
        title = "Фильтры"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
}

extension TrackerFiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        cell.textLabel?.text = filterOptions[indexPath.row]
        
        let isSelected: Bool
        switch indexPath.row {
        case 0: isSelected = selectedFilter == .all
        case 1: isSelected = selectedFilter == .today
        case 2: isSelected = selectedFilter == .completed
        case 3: isSelected = selectedFilter == .uncompleted
        default: isSelected = false
        }
        
        // "Все трекеры" и "Трекеры на сегодня" - это сброс фильтрации, галочку не показываем
        let shouldShowCheckmark = (indexPath.row == 2 || indexPath.row == 3) && isSelected
        cell.accessoryType = shouldShowCheckmark ? .checkmark : .none
        
        return cell
    }
}

extension TrackerFiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75 // Высота строки
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let newFilter: TrackerFilter
        switch indexPath.row {
        case 0: newFilter = .all
        case 1: newFilter = .today
        case 2: newFilter = .completed
        case 3: newFilter = .uncompleted
        default: newFilter = .all
        }
        
        AnalyticsService.shared.report(event: "click", params: [
            "screen": "Filters",
            "item": "apply_filter",
            "filter_type": newFilter
        ])
        
        // Передаем выбранный фильтр, даже если он тот же самый
        onFilterSelected?(newFilter)
        
        dismiss(animated: true)
    }
}
