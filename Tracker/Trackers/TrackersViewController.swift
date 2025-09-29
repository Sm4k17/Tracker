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
            // Navigation
            static let datePickerWidth: CGFloat = 77
            static let datePickerHeight: CGFloat = 34
            
            // Content
            static let collectionViewTopInset: CGFloat = 16
            
            // Placeholder
            static let placeholderImageSize: CGFloat = 80
            static let placeholderSpacing: CGFloat = 8
            
            // COLLECTION VIEW CONSTANTS
            static let collectionItemSpacing: CGFloat = 12
            static let collectionLineSpacing: CGFloat = 16
            static let collectionSectionInsetTop: CGFloat = 12
            static let collectionSectionInsetLeft: CGFloat = 16
            static let collectionSectionInsetBottom: CGFloat = 16
            static let collectionSectionInsetRight: CGFloat = 16
            static let collectionItemHeight: CGFloat = 148
            static let collectionHeaderHeight: CGFloat = 18
            static let collectionItemsPerRow: CGFloat = 2
            
            // КОНСТАНТЫ ДЛЯ SEARCH CONTROLLER
            static let searchTextFieldCornerRadius: CGFloat = 10
            static let searchTextFieldFontSize: CGFloat = 17
            
            // Вычисляемые константы
            static var collectionTotalHorizontalInset: CGFloat {
                collectionSectionInsetLeft + collectionSectionInsetRight + collectionItemSpacing
            }
        }
        
        // ЦВЕТА ДЛЯ ТЕКСТА
        enum Colors {
            static let searchPlaceholder: UIColor = .ypGray
            static let searchText: UIColor = .ypBlack
            static let dateButtonText: UIColor = .ypBlack
        }
    }
    
    // MARK: - UI Components
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite
        return view
    }()
    
    // Кнопка "+" в левой части navigation bar
    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: Constants.addButtonImageName),
            primaryAction: UIAction { [weak self] _ in
                self?.didTapAddButton()
            }
        )
        button.tintColor = .ypBlack
        return button
    }()
    
    // Основной DatePicker
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        
        datePicker.addAction(UIAction { [weak self] _ in
            self?.dateChanged(datePicker)
        }, for: .valueChanged)
        
        return datePicker
    }()
    
    // SearchController для поиска трекеров
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        
        let searchTextField = searchController.searchBar.searchTextField
        
        // Настройка через константы
        searchTextField.font = UIFont.systemFont(
            ofSize: Constants.Layout.searchTextFieldFontSize,
            weight: .regular
        )
        searchTextField.textColor = Constants.Colors.searchText
        
        searchTextField.leftView?.tintColor = .ypGray
        
        searchTextField.layer.cornerRadius = Constants.Layout.searchTextFieldCornerRadius
        searchTextField.layer.masksToBounds = true
        
        // Кастомный placeholder
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: Constants.searchPlaceholder,
            attributes: [
                .foregroundColor: Constants.Colors.searchPlaceholder,
                .font: UIFont.systemFont(
                    ofSize: Constants.Layout.searchTextFieldFontSize,
                    weight: .regular
                )
            ]
        )
        
        return searchController
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
        
        // ИСПОЛЬЗУЕМ КОНСТАНТЫ ДЛЯ НАСТРОЙКИ LAYOUT
        layout.minimumInteritemSpacing = Constants.Layout.collectionItemSpacing
        layout.minimumLineSpacing = Constants.Layout.collectionLineSpacing
        layout.sectionInset = UIEdgeInsets(
            top: Constants.Layout.collectionSectionInsetTop,
            left: Constants.Layout.collectionSectionInsetLeft,
            bottom: Constants.Layout.collectionSectionInsetBottom,
            right: Constants.Layout.collectionSectionInsetRight
        )
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .ypWhite
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        // ДОБАВИМ ДЛЯ БУДУЩЕГО ИСПОЛЬЗОВАНИЯ
        collection.showsVerticalScrollIndicator = false
        collection.alwaysBounceVertical = true
        
        return collection
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .ypWhite
        setupViews()
        setupConstraints()
        setupCollectionView()
    }
    
    // MARK: - Date Formatter
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy" // ✅ Формат "13.05.21"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    private func setupCollectionView() {
        //collectionView.delegate = self
        //collectionView.dataSource = self
        
        collectionView.isHidden = true
        placeholderStackView.isHidden = false
    }
    
    private func setupNavigationBar() {
        title = Constants.navigationTitle
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        // Настройка внешнего вида navigation bar
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.ypBlack,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func setupViews() {
        // Обновленная иерархия
        [contentView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        [placeholderStackView, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        placeholderStackView.addArrangedSubview(placeholderImageView)
        placeholderStackView.addArrangedSubview(placeholderLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            // Content View
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                             constant: Constants.Layout.collectionViewTopInset),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Collection View внутри contentView
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Placeholder Stack View
            placeholderStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Placeholder Image
            placeholderImageView.widthAnchor.constraint(equalToConstant: Constants.Layout.placeholderImageSize),
            placeholderImageView.heightAnchor.constraint(equalToConstant: Constants.Layout.placeholderImageSize)
        ])
    }
    
    private func calculateCollectionViewItemSize() -> CGSize {
        let totalWidth = view.bounds.width - Constants.Layout.collectionTotalHorizontalInset
        let itemWidth = totalWidth / Constants.Layout.collectionItemsPerRow
        
        return CGSize(
            width: itemWidth,
            height: Constants.Layout.collectionItemHeight
        )
    }
    
    // MARK: - Actions
    private func didTapAddButton() {
        print("Add button tapped")
    }
    
    private func dateChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Date changed: \(formattedDate)") // Будет "29.09.25"
        
        // Здесь будет логика фильтрации трекеров по дате
    }
}

// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        print("Search text: \(searchText)")
        // Здесь будет логика фильтрации по поиску
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

