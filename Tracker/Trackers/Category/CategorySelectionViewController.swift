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
            static let cornerRadius: CGFloat = 16
            static let separatorHeight: CGFloat = 1
            static let separatorInset: CGFloat = 16
            static let stackViewTopInset: CGFloat = 24
        }
        
        enum Fonts {
            static let categoryLabel: UIFont = .systemFont(ofSize: 17, weight: .regular)
            static let button: UIFont = .systemFont(ofSize: 16, weight: .medium)
        }
        
        enum Colors {
            static let categoryLabel: UIColor = .ypBlack
            static let buttonText: UIColor = .ypWhite
            static let stackViewBackground: UIColor = .ypBackgroundDay
            static let separator: UIColor = .ypGray
            static let checkmark: UIColor = .ypBlue
        }
    }
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var categoriesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.backgroundColor = Constants.Colors.stackViewBackground
        stackView.layer.cornerRadius = Constants.Layout.cornerRadius
        stackView.layer.masksToBounds = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isHidden = true // Сначала скрываем, пока нет данных
        return stackView
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.addCategoryButtonTitle, for: .normal)
        button.titleLabel?.font = Constants.Fonts.button
        button.backgroundColor = .ypBlack
        button.setTitleColor(Constants.Colors.buttonText, for: .normal)
        button.layer.cornerRadius = Constants.Layout.cornerRadius
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
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(categoriesStackView)
        view.addSubview(addCategoryButton)
        view.addSubview(placeholderStackView)
        
        // Настраиваем плейсхолдер
        placeholderStackView.addArrangedSubview(placeholderImageView)
        placeholderStackView.addArrangedSubview(placeholderLabel)
        
        // Устанавливаем размеры для изображения плейсхолдера
        NSLayoutConstraint.activate([
            placeholderImageView.widthAnchor.constraint(equalToConstant: Constants.Layout.placeholderImageSize),
            placeholderImageView.heightAnchor.constraint(equalToConstant: Constants.Layout.placeholderImageSize)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Скролл вью занимает все пространство над кнопкой
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
            
            // Контент вью внутри скролла
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Стек категорий внутри контент вью
            categoriesStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Layout.stackViewTopInset),
            categoriesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.horizontalInset),
            categoriesStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.horizontalInset),
            categoriesStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            // Кнопка всегда внизу
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.horizontalInset),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.horizontalInset),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Layout.buttonBottomInset),
            
            // Плейсхолдер по центру экрана
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Categories Setup
    private func setupCategories() {
        // Очищаем стек перед добавлением новых элементов
        categoriesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, category) in categories.enumerated() {
            let categoryLabel = createCategoryLabel(for: category)
            let checkmarkImageView = createCheckmarkImageView(for: category)
            
            let horizontalStack = UIStackView(arrangedSubviews: [categoryLabel, checkmarkImageView])
            horizontalStack.axis = .horizontal
            horizontalStack.distribution = .equalSpacing
            horizontalStack.alignment = .center
            horizontalStack.isLayoutMarginsRelativeArrangement = true
            horizontalStack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            
            let containerView = UIView()
            containerView.addSubview(horizontalStack)
            horizontalStack.translatesAutoresizingMaskIntoConstraints = false
            
            // Устанавливаем фиксированную высоту для контейнера
            containerView.heightAnchor.constraint(equalToConstant: Constants.Layout.rowHeight).isActive = true
            
            NSLayoutConstraint.activate([
                horizontalStack.topAnchor.constraint(equalTo: containerView.topAnchor),
                horizontalStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                horizontalStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                horizontalStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            
            // Добавляем разделитель для всех элементов кроме последнего
            if index < categories.count - 1 {
                insertSeparatorLine(to: containerView)
            }
            
            // Добавляем обработчик нажатия
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCategory(_:)))
            containerView.addGestureRecognizer(tapGesture)
            containerView.isUserInteractionEnabled = true
            containerView.tag = index // Сохраняем индекс для идентификации
            
            categoriesStackView.addArrangedSubview(containerView)
        }
    }
    
    private func createCategoryLabel(for category: String) -> UILabel {
        let label = UILabel()
        label.text = category
        label.font = Constants.Fonts.categoryLabel
        label.textColor = Constants.Colors.categoryLabel
        return label
    }
    
    private func createCheckmarkImageView(for category: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Constants.Colors.checkmark
        
        if category == selectedCategory {
            imageView.image = UIImage(systemName: "checkmark")
        } else {
            imageView.image = nil
        }
        
        // Устанавливаем размер для галочки
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        return imageView
    }
    
    private func insertSeparatorLine(to containerView: UIView) {
        let separator = UIView()
        separator.backgroundColor = Constants.Colors.separator
        containerView.addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.Layout.separatorInset),
            separator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.Layout.separatorInset),
            separator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: Constants.Layout.separatorHeight)
        ])
    }
    
    // MARK: - UI State Management
    private func updateUIState() {
        let isEmpty = categories.isEmpty
        
        // Показываем либо стек категорий, либо плейсхолдер
        categoriesStackView.isHidden = isEmpty
        placeholderStackView.isHidden = !isEmpty
        scrollView.isHidden = isEmpty // Скрываем скролл когда нет категорий
        
        if !isEmpty {
            setupCategories()
        }
        
        // Анимируем изменения
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Actions
    @objc private func didTapCategory(_ gesture: UITapGestureRecognizer) {
        guard let containerView = gesture.view else { return }
        let index = containerView.tag
        let selectedCategory = categories[index]
        onCategorySelected(selectedCategory)
        navigationController?.popViewController(animated: true)
    }
    
    private func didTapAddCategoryButton() {
        let addCategoryVC = AddCategoryViewController { [weak self] newCategory in
            self?.categories.append(newCategory)
            self?.updateUIState() // Обновляем состояние UI
            self?.onCategorySelected(newCategory)
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(addCategoryVC, animated: true)
    }
}
