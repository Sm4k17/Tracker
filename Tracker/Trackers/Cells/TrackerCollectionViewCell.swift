//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 03.10.2025.
//

import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCell"
    
    weak var delegate: TrackerCellDelegate?
    private var trackerId: UUID?
    private var contextMenuInteraction: UIContextMenuInteraction?
    
    // UI Components (остаются без изменений)
    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        return label
    }()
    
    // Иконка закрепления
    private let pinIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "pin.fill")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        plusButton.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
        
        // Настраиваем контекстное меню только для cardView
        setupContextMenu()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(cardView)
        cardView.addSubview(emojiLabel)
        cardView.addSubview(pinIcon)
        cardView.addSubview(titleLabel)
        contentView.addSubview(daysCountLabel)
        contentView.addSubview(plusButton)
        
        [cardView, emojiLabel, pinIcon, titleLabel, daysCountLabel, plusButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // Иконка закрепления в правом верхнем углу cardView
            pinIcon.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            pinIcon.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -4),
            pinIcon.widthAnchor.constraint(equalToConstant: 16),
            pinIcon.heightAnchor.constraint(equalToConstant: 16),
            
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            daysCountLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            plusButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    private func setupContextMenu() {
        // Создаем interaction и добавляем ТОЛЬКО к cardView
        contextMenuInteraction = UIContextMenuInteraction(delegate: self)
        cardView.addInteraction(contextMenuInteraction!)
        
        // Делаем cardView доступной для взаимодействий
        cardView.isUserInteractionEnabled = true
    }
    
    @objc private func didTapPlusButton() {
        delegate?.didTapPlusButton(in: self)
    }
    
    func configure(with viewModel: TrackerViewModel, animated: Bool = false) {
        trackerId = viewModel.tracker.idTrackers
        
        titleLabel.text = viewModel.tracker.name
        emojiLabel.text = viewModel.tracker.emoji
        cardView.backgroundColor = viewModel.tracker.color
        
        // Показываем/скрываем иконку закрепления
        pinIcon.isHidden = !viewModel.tracker.isPinned
        
        daysCountLabel.text = dayString(for: viewModel.completedDays)
        
        let changes = {
            // Общие свойства для всех состояний
            self.plusButton.tintColor = .white
            self.plusButton.alpha = 1.0
            
            if viewModel.isFutureDate {
                self.plusButton.backgroundColor = viewModel.tracker.color.withAlphaComponent(0.3)
                self.plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
                self.plusButton.isEnabled = false
            } else if viewModel.isCompletedToday {
                self.plusButton.backgroundColor = viewModel.tracker.color.withAlphaComponent(0.3)
                self.plusButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
                self.plusButton.isEnabled = true
            } else {
                self.plusButton.backgroundColor = viewModel.tracker.color
                self.plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
                self.plusButton.isEnabled = true
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                changes()
            }
        } else {
            changes()
        }
    }
    
    private func dayString(for count: Int) -> String {
        let format = NSLocalizedString("days_count", comment: "Number of days completed")
        return String.localizedStringWithFormat(format, count)
    }
}

// MARK: - UIContextMenuInteractionDelegate
extension TrackerCollectionViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let trackerId = trackerId else { return nil }
        
        // Анимируем выделение ТОЛЬКО cardView при появлении меню
        UIView.animate(withDuration: 0.2) {
            self.cardView.alpha = 0.7
            self.cardView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
        
        let pinTitle = pinIcon.isHidden ? R.string.localizable.pin() : R.string.localizable.unpin()
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let pin = UIAction(title: pinTitle) { [weak self] _ in
                self?.delegate?.didTogglePin(for: trackerId)
            }
            
            let edit = UIAction(title: R.string.localizable.edit()) { [weak self] _ in
                self?.delegate?.didRequestEdit(for: trackerId)
            }
            
            let delete = UIAction(
                title: R.string.localizable.delete(),
                attributes: .destructive
            ) { [weak self] _ in
                self?.delegate?.didRequestDelete(for: trackerId)
            }
            
            return UIMenu(title: "", children: [pin, edit, delete])
        }
    }
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        willEndFor configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionAnimating?
    ) {
        // Возвращаем cardView к нормальному состоянию когда меню скрывается
        animator?.addCompletion {
            UIView.animate(withDuration: 0.2) {
                self.cardView.alpha = 1.0
                self.cardView.transform = .identity
            }
        }
    }
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        // Создаем preview ТОЛЬКО для cardView (без дней и кнопки)
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(roundedRect: cardView.bounds, cornerRadius: 16)
        
        return UITargetedPreview(view: cardView, parameters: parameters)
    }
}
