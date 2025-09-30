//
//  CategorySelectionViewController.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 30.09.2025.
//

import UIKit

final class CategorySelectionViewController: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let navigationTitle = "Категория"
        static let addCategoryButtonTitle = "Добавить категорию"
        static let placeholderTitle = "Привычки и события можно\nобъединить по смыслу"
        static let placeholderImageName = "icDizzy"
        
        enum Layout {
            static let horizontalInset: CGFloat = 16
            static let rowHeight: CGFloat = 75
            static let placeholderImageSize: CGFloat = 80
            static let placeholderSpacing: CGFloat = 8
            static let buttonBottomInset: CGFloat = 16
        }
    }
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        table.backgroundColor = .ypWhite
        table.separatorStyle = .singleLine
        table.layer.cornerRadius = 16
        table.layer.masksToBounds = true
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isHidden = true // Сначала скрываем, пока нет данных
        return table
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.addCategoryButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        button.addAction(UIAction { [weak self] _ in
            self?.didTapAddCategoryButton()
        }, for: .touchUpInside)
        
        return button
    }()
    
    // Плейсхолдер для пустого состояния
    private lazy var placeholderStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = Constants.Layout.placeholderSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: Constants.placeholderImageName)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = .ypBlack
        label.text = Constants.placeholderTitle
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Properties
    private let selectedCategory: String
    private let onCategorySelected: (String) -> Void
    private var categories: [String] = [] // Начинаем с пустого массива
    
    // MARK: - Initializer
    init(selectedCategory: String, onCategorySelected: @escaping (String) -> Void) {
        self.selectedCategory = selectedCategory
        self.onCategorySelected = onCategorySelected
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUIState()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .ypWhite
        setupNavigationBar()
        setupViews()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        title = Constants.navigationTitle
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
    }
    
    private func setupViews() {
        // Добавляем все основные элементы
        view.addSubview(tableView)
        view.addSubview(addCategoryButton)
        view.addSubview(placeholderStackView)
        
        // Настраиваем плейсхолдер
        placeholderStackView.addArrangedSubview(placeholderImageView)
        placeholderStackView.addArrangedSubview(placeholderLabel)
        
        // Настраиваем таблицу
        tableView.delegate = self
        tableView.dataSource = self
        
        // Устанавливаем размеры для изображения плейсхолдера
        NSLayoutConstraint.activate([
            placeholderImageView.widthAnchor.constraint(equalToConstant: Constants.Layout.placeholderImageSize),
            placeholderImageView.heightAnchor.constraint(equalToConstant: Constants.Layout.placeholderImageSize)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Кнопка всегда внизу
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.horizontalInset),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.horizontalInset),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Layout.buttonBottomInset),
            
            // Таблица над кнопкой
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.horizontalInset),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.horizontalInset),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -24),
            
            // Плейсхолдер по центру экрана
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - UI State Management
    private func updateUIState() {
        let isEmpty = categories.isEmpty
        
        // Показываем либо таблицу, либо плейсхолдер
        tableView.isHidden = isEmpty
        placeholderStackView.isHidden = !isEmpty
        
        if !isEmpty {
            // Обновляем высоту таблицы когда есть данные
            let tableHeight = CGFloat(categories.count) * Constants.Layout.rowHeight
            // Ограничиваем максимальную высоту таблицы
            let maxTableHeight = tableView.frame.height
            tableView.constraints.first(where: { $0.firstAttribute == .height })?.isActive = false
            tableView.heightAnchor.constraint(equalToConstant: min(tableHeight, maxTableHeight)).isActive = true
        }
        
        // Анимируем изменения
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Actions
    private func didTapAddCategoryButton() {
        let addCategoryVC = AddCategoryViewController { [weak self] newCategory in
            self?.categories.append(newCategory)
            self?.tableView.reloadData()
            self?.updateUIState() // Обновляем состояние UI
            self?.onCategorySelected(newCategory)
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(addCategoryVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CategorySelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        // Галочка для выбранной категории
        if category == selectedCategory {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Layout.rowHeight
    }
}

// MARK: - UITableViewDelegate
extension CategorySelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCategory = categories[indexPath.row]
        onCategorySelected(selectedCategory)
        navigationController?.popViewController(animated: true)
    }
}
