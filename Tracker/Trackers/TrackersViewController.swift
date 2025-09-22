//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 08.09.2025.
//

import UIKit

// MARK: - Main View Controller
final class TrackersViewController: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let navigationTitle = "Трекеры"
        static let placeholderTitle = "Что будем отслеживать?"
        static let placeholderImageName = "icDizzy"
        static let addButtonImageName = "plus"
        static let searchPlaceholder = "Поиск"
        
        // Константы для размеров и отступов
        enum Layout {
            static let datePickerWidth: CGFloat = 95
            static let searchBarHeight: CGFloat = 36
            static let searchBarTopInset: CGFloat = 10
            static let searchBarHorizontalInset: CGFloat = 16
            static let collectionViewTopInset: CGFloat = 16
            static let placeholderImageSize: CGFloat = 80
            static let placeholderSpacing: CGFloat = 8
        }
    }
    
    // MARK: - UI Components
    private lazy var navigationBar: UINavigationBar = {
        let bar = UINavigationBar()
        bar.barTintColor = .ypWhite
        return bar
    }()
    
    // Кнопка "+" в левой части navigation bar
    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: Constants.addButtonImageName),
            style: .plain,
            target: self,
            action: #selector(didTapAddButton)
        )
        button.tintColor = .ypBlack
        return button
    }()
    
    // DatePicker для выбора даты в правой части navigation bar
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ru_CH")
        
        // Черный цвет текста даты
        if #available(iOS 14.0, *) {
            picker.tintColor = .ypBlack
        } else {
            picker.setValue(UIColor.ypBlack, forKey: "textColor")
        }
        return picker
    }()
    
    // Search bar для поиска трекеров
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = Constants.searchPlaceholder
        searchBar.searchBarStyle = .minimal
        
        // Настройка внешнего вида
        searchBar.searchTextField.backgroundColor = .clear
        searchBar.tintColor = .systemBlue
        searchBar.searchTextField.textColor = .ypBlack
        searchBar.searchTextField.font = .systemFont(ofSize: 16)
        
        // Убираем стандартные фоны
        searchBar.backgroundImage = UIImage()
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        // Кастомная граница
        searchBar.searchTextField.layer.borderWidth = 1
        searchBar.searchTextField.layer.borderColor = UIColor.systemGray4.cgColor
        searchBar.searchTextField.layer.cornerRadius = 8
        searchBar.searchTextField.layer.masksToBounds = true
        
        return searchBar
    }()
    
    // StackView для размещения иконки и текста плейсхолдера
    private lazy var placeholderStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = Constants.Layout.placeholderSpacing
        return stack
    }()
    
    // Иконка плейсхолдера (когда нет трекеров)
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: Constants.placeholderImageName)
        return imageView
    }()
    
    // Текст плейсхолдера
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = .ypBlack
        label.text = Constants.placeholderTitle
        return label
    }()
    
    // CollectionView для отображения списка трекеров
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .ypWhite
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        return collection
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .ypWhite
        setupViews()
        setupConstraints()
        setupNavigationBarAppearance()
    }
    
    private func setupViews() {
        // Добавляем все view в иерархию и отключаем авто-размеры
        [navigationBar, searchBar, placeholderStackView, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        // Добавляем элементы в stack view
        placeholderStackView.addArrangedSubview(placeholderImageView)
        placeholderStackView.addArrangedSubview(placeholderLabel)
        
        // Настройка navigation bar
        let navItem = UINavigationItem(title: Constants.navigationTitle)
        navItem.leftBarButtonItem = addButton
        navItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationBar.items = [navItem]
        
        // Настройка datePicker constraints
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        // Отступы для текста в search bar
        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 8, vertical: 0)
        
        collectionView.isHidden = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Navigation Bar - привязываем к safe area сверху и по бокам
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Date Picker - фиксированная ширина
            datePicker.widthAnchor.constraint(equalToConstant: Constants.Layout.datePickerWidth),
            
            // Search Bar - под navigation bar с отступами
            searchBar.topAnchor.constraint(equalTo: navigationBar.bottomAnchor,
                                          constant: Constants.Layout.searchBarTopInset),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                              constant: Constants.Layout.searchBarHorizontalInset),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                               constant: -Constants.Layout.searchBarHorizontalInset),
            searchBar.heightAnchor.constraint(equalToConstant: Constants.Layout.searchBarHeight),
            
            // Collection View - растягиваем на весь оставшийся экран
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor,
                                               constant: Constants.Layout.collectionViewTopInset),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Placeholder Stack View - центрируем по всему экрану
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Placeholder Image - фиксированный размер
            placeholderImageView.widthAnchor.constraint(equalToConstant: Constants.Layout.placeholderImageSize),
            placeholderImageView.heightAnchor.constraint(equalToConstant: Constants.Layout.placeholderImageSize)
        ])
    }
    
    // Отдельный метод для настройки внешнего вида navigation bar
    private func setupNavigationBarAppearance() {
        navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.ypBlack,
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
    }
    
    // MARK: - Actions
    @objc private func didTapAddButton() {
        print("Add button tapped")
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview("Trackers View") {
    let viewController = TrackersViewController()
    return viewController
}
#endif
