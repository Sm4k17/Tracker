//
//  CategorySelectionViewController.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 30.09.2025.
//

import UIKit

// MARK: - Category Selection View Controller
final class CategorySelectionViewController: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let navigationTitle = "Категория"
        static let addCategoryButtonTitle = "Добавить категорию"
        static let placeholderTitle = "Привычки и события можно\nобъединить по смыслу"
        static let placeholderImageName = "icDizzy"
        
        static let buttonHorizontalInset: CGFloat = 20
        static let buttonBottomOffset: CGFloat = 16
        static let tableTopInset: CGFloat = 24
        static let tableBottomOffset: CGFloat = 24
        static let horizontalPadding: CGFloat = 16
        static let dizzyImageSize: CGFloat = 80
        static let heightForRowAt: CGFloat = 75
        static let tableCornerRadius: CGFloat = 16
        static let labelNumberOfLines: Int = 2
        static let stackSpacing: CGFloat = 8
    }
    
    // MARK: - UI Components
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.addCategoryButtonTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
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
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.isOpaque = true
        tableView.clearsContextBeforeDrawing = true
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = Constants.tableCornerRadius
        tableView.separatorColor = .ypGray
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(
            top: 0, left: Constants.horizontalPadding, bottom: 0, right: Constants.horizontalPadding)
        tableView.isEditing = false
        tableView.allowsSelection = true
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        return tableView
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let image = UIImage(named: Constants.placeholderImageName)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isHidden = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.placeholderTitle
        label.textColor = .ypBlack
        label.numberOfLines = Constants.labelNumberOfLines
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var placeholderStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [placeholderImageView, placeholderLabel])
        stack.axis = .vertical
        stack.spacing = Constants.stackSpacing
        stack.alignment = .center
        stack.isHidden = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Properties
    private let selectedCategory: String
    private let onCategorySelected: (String) -> Void
    private var categories: [String] = []
    
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
        setupNavigationBar()
        updateUIState()
        // ВРЕМЕННО: добавляем тестовые категории
        categories = ["Важное", "Работа", "Личное"]
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .ypWhite
        setupViews()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        title = Constants.navigationTitle
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = nil
    }
    
    private func setupViews() {
        view.addSubview(addCategoryButton)
        view.addSubview(tableView)
        view.addSubview(placeholderStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            addCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                      constant: Constants.buttonHorizontalInset),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                       constant: -Constants.buttonHorizontalInset),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                     constant: -Constants.buttonBottomOffset),
            
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            // ИЗМЕНЕНИЕ: убираем top отступ, чтобы таблица начиналась сразу под navigation bar
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -Constants.tableBottomOffset),
            
            placeholderImageView.widthAnchor.constraint(equalToConstant: Constants.dizzyImageSize),
            placeholderImageView.heightAnchor.constraint(equalToConstant: Constants.dizzyImageSize),
            
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horizontalPadding),
            placeholderStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horizontalPadding),
        ])
    }
    
    // MARK: - UI State Management
    private func updateUIState() {
        let isEmpty = categories.isEmpty
        placeholderStackView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    // MARK: - Actions
    private func didTapAddCategoryButton() {
        let addCategoryVC = AddCategoryViewController { [weak self] newCategory in
            self?.categories.append(newCategory)
            self?.updateUIState()
            self?.tableView.reloadData()
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
        
        // Конфигурация ячейки
        cell.textLabel?.text = category
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = .ypBlack
        cell.backgroundColor = .ypBackgroundDay
        cell.selectionStyle = .none
        
        // Галочка для выбранной категории
        if category == selectedCategory {
            cell.accessoryType = .checkmark
            cell.tintColor = .ypBlue
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategorySelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.heightForRowAt
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.tableTopInset // 24
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = categories[indexPath.row]
        onCategorySelected(selectedCategory)
        navigationController?.popViewController(animated: true)
    }
}
