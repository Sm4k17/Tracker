//
//  EmojiSelectionViewController.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 30.09.2025.
//

import UIKit

final class EmojiSelectionView: UIView {
    
    // MARK: - Constants
    enum Constants {
        static let emojis = [
            "🙂", "😻", "🌺", "🐶", "❤️", "😱",
            "😇", "😡", "🥶", "🤔", "🙌", "🍔",
            "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
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
        collection.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collection.isScrollEnabled = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    // MARK: - Properties
    private var selectedEmoji: String = ""
    weak var delegate: EmojiSelectionDelegate?
    
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
    func setSelectedEmoji(_ emoji: String) {
        let oldSelectedEmoji = selectedEmoji
        selectedEmoji = emoji
        
        // Находим индексы старого и нового выбранного emoji
        var indexPathsToUpdate: [IndexPath] = []
        
        if let oldIndex = Constants.emojis.firstIndex(of: oldSelectedEmoji) {
            indexPathsToUpdate.append(IndexPath(item: oldIndex, section: 0))
        }
        
        if let newIndex = Constants.emojis.firstIndex(of: emoji) {
            indexPathsToUpdate.append(IndexPath(item: newIndex, section: 0))
        }
        
        // Убираем дубликаты (если старый и новый emoji одинаковые)
        indexPathsToUpdate = Array(Set(indexPathsToUpdate))
        
        // Если есть что обновлять - обновляем только нужные ячейки
        if !indexPathsToUpdate.isEmpty {
            collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: indexPathsToUpdate)
            })
        }
    }
    
    func calculateHeight() -> CGFloat {
        return Layout.calculateCollectionHeight(itemCount: Constants.emojis.count)
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension EmojiSelectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
        let emoji = Constants.emojis[indexPath.item]
        let isSelected = emoji == selectedEmoji
        cell.configure(with: emoji, isSelected: isSelected)
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
        let oldSelectedIndex = Constants.emojis.firstIndex(of: selectedEmoji)
        selectedEmoji = Constants.emojis[indexPath.item]
        
        // ЗАМЕНА: обновляем только старую и новую выбранную ячейку
        var indexPathsToUpdate = [indexPath]
        if let oldIndex = oldSelectedIndex, oldIndex != indexPath.item {
            indexPathsToUpdate.append(IndexPath(item: oldIndex, section: 0))
        }
        
        collectionView.performBatchUpdates {
            collectionView.reloadItems(at: indexPathsToUpdate)
        }
        
        delegate?.didSelectEmoji(selectedEmoji)
    }
}

// MARK: - EmojiCell
private final class EmojiCell: UICollectionViewCell {
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectionView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .ypLightGray
        view.isHidden = true
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
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            selectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionView.widthAnchor.constraint(equalToConstant: 52),
            selectionView.heightAnchor.constraint(equalToConstant: 52),
            
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with emoji: String, isSelected: Bool) {
        emojiLabel.text = emoji
        selectionView.isHidden = !isSelected
    }
}
