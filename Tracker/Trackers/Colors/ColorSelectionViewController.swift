//
//  ColorSelectionViewController.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 30.09.2025.
//

import UIKit

final class ColorSelectionView: UIView {
    
    // MARK: - Constants
    enum Constants {
        static let colors: [UIColor] = [
            .colorSelection1, .colorSelection2, .colorSelection3,
            .colorSelection4, .colorSelection5, .colorSelection6,
            .colorSelection7, .colorSelection8, .colorSelection9,
            .colorSelection10, .colorSelection11, .colorSelection12,
            .colorSelection13, .colorSelection14, .colorSelection15,
            .colorSelection16, .colorSelection17, .colorSelection18
        ]
    }
    
    enum Layout {
        static let itemSpacing: CGFloat = 5
        static let lineSpacing: CGFloat = 0
        static let itemsPerRow: CGFloat = 6
        static let itemSize: CGFloat = 52
        
        // Общий метод для расчета высоты
        static func calculateCollectionHeight(itemCount: Int) -> CGFloat {
            let rows = ceil(CGFloat(itemCount) / itemsPerRow)
            let totalSpacing = (rows - 1) * lineSpacing
            return (itemSize * rows) + totalSpacing
        }
    }
    
    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = Layout.itemSpacing
        layout.minimumLineSpacing = Layout.lineSpacing
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .ypWhite
        collection.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        collection.isScrollEnabled = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    // MARK: - Properties
    private var selectedColor: UIColor = .systemRed
    weak var delegate: ColorSelectionDelegate?
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        addSubview(collectionView)
        setupConstraints()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    func setSelectedColor(_ color: UIColor) {
        let oldSelectedColor = selectedColor
        selectedColor = color
        
        // Находим индексы старого и нового выбранного цвета
        var indexPathsToUpdate: [IndexPath] = []
        
        if let oldIndex = Constants.colors.firstIndex(where: { $0 == oldSelectedColor }) {
            indexPathsToUpdate.append(IndexPath(item: oldIndex, section: 0))
        }
        
        if let newIndex = Constants.colors.firstIndex(where: { $0 == color }) {
            indexPathsToUpdate.append(IndexPath(item: newIndex, section: 0))
        }
        
        // Убираем дубликаты (если старый и новый цвет одинаковые)
        indexPathsToUpdate = Array(Set(indexPathsToUpdate))
        
        // Если есть что обновлять - обновляем только нужные ячейки
        if !indexPathsToUpdate.isEmpty {
            collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: indexPathsToUpdate)
            })
        }
    }
    
    func calculateHeight() -> CGFloat {
        return Layout.calculateCollectionHeight(itemCount: Constants.colors.count)
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension ColorSelectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
        let color = Constants.colors[indexPath.item]
        let isSelected = color == selectedColor
        cell.configure(with: color, isSelected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Layout.itemSize, height: Layout.itemSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Layout.lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Layout.itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let oldSelectedIndex = Constants.colors.firstIndex(where: { $0 == selectedColor })
        selectedColor = Constants.colors[indexPath.item]
        
        // ЗАМЕНА: обновляем только старую и новую выбранную ячейку
        var indexPathsToUpdate = [indexPath]
        if let oldIndex = oldSelectedIndex, oldIndex != indexPath.item {
            indexPathsToUpdate.append(IndexPath(item: oldIndex, section: 0))
        }
        
        collectionView.performBatchUpdates({
            self.collectionView.reloadItems(at: indexPathsToUpdate)
        })
        
        delegate?.didSelectColor(selectedColor)
    }
}

// MARK: - ColorCell
private final class ColorCell: UICollectionViewCell {
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let selectionView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.clear.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(selectionView)
        selectionView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            selectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionView.widthAnchor.constraint(equalToConstant: 52),
            selectionView.heightAnchor.constraint(equalToConstant: 52),
            
            colorView.centerXAnchor.constraint(equalTo: selectionView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: selectionView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(with color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        selectionView.layer.borderColor = isSelected ? color.withAlphaComponent(0.3).cgColor : UIColor.clear.cgColor
    }
}
