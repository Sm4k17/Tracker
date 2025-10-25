//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 03.10.2025.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didTapPlusButton(in cell: TrackerCollectionViewCell)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCell"
    
    weak var delegate: TrackerCellDelegate?
    private var trackerId: UUID?
    
    // UI Components
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(cardView)
        cardView.addSubview(emojiLabel)
        cardView.addSubview(titleLabel)
        contentView.addSubview(daysCountLabel)
        contentView.addSubview(plusButton)
        
        [cardView, emojiLabel, titleLabel, daysCountLabel, plusButton].forEach {
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
    
    @objc private func didTapPlusButton() {
        delegate?.didTapPlusButton(in: self)
    }
    
    func configure(with viewModel: TrackerViewModel, animated: Bool = false) {
        trackerId = viewModel.tracker.idTrackers
        titleLabel.text = viewModel.tracker.name
        emojiLabel.text = viewModel.tracker.emoji
        cardView.backgroundColor = viewModel.tracker.color
        
        daysCountLabel.text = "\(viewModel.completedDays) \(dayString(for: viewModel.completedDays))"
        
        let changes = {
            // Общие свойства для всех состояний
            self.plusButton.tintColor = .white
            self.plusButton.alpha = 1.0
            
            if viewModel.isFutureDate {
                // ДЛЯ БУДУЩИХ ДНЕЙ - полупрозрачная и неактивная
                self.plusButton.backgroundColor = viewModel.tracker.color.withAlphaComponent(0.3)
                self.plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
                self.plusButton.isEnabled = false
            } else if viewModel.isCompletedToday {
                // УЖЕ ВЫПОЛНЕН СЕГОДНЯ
                self.plusButton.backgroundColor = viewModel.tracker.color.withAlphaComponent(0.3)
                self.plusButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
                self.plusButton.isEnabled = true
            } else {
                // ДОСТУПЕН ДЛЯ ВЫПОЛНЕНИЯ
                self.plusButton.backgroundColor = viewModel.tracker.color
                self.plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
                self.plusButton.isEnabled = true
            }
        }
        
        if animated {
            // Анимация только для сегодняшних дней при изменении состояния
            UIView.animate(withDuration: 0.3) {
                changes()
            }
        } else {
            // Без анимации для первоначальной настройки
            changes()
        }
    }
    
    private func dayString(for count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        
        if lastDigit == 1 && lastTwoDigits != 11 { return "day".localized }
        if (2...4).contains(lastDigit) && !(12...14).contains(lastTwoDigits) { return "days".localized }
        return "days_many".localized
    }
}
