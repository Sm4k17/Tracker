//
//  StatisticCardCell.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 06.11.2025.
//

import UIKit

final class StatisticCard: UIView {

    private enum Constants {
        static let cornerRadius: CGFloat = 16
        static let innerCornerRadius: CGFloat = 14
        static let borderWidth: CGFloat = 1

        static let contentTopInset: CGFloat = 12
        static let contentHorizontalInset: CGFloat = 12
        static let contentSpacing: CGFloat = 7
        static let contentBottomInset: CGFloat = 12

        enum Font {
            static let number: UIFont = .systemFont(ofSize: 34, weight: .bold)
            static let description: UIFont = .systemFont(ofSize: 12)
        }
    }

    private let gradientBorderView = GradientBorderView()
    private let containerView = UIView()
    private let numberLabel = UILabel()
    private let descriptionLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        gradientBorderView.layer.cornerRadius = Constants.cornerRadius
        gradientBorderView.clipsToBounds = true
        gradientBorderView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gradientBorderView)

        containerView.backgroundColor = .ypWhite
        containerView.layer.cornerRadius = Constants.innerCornerRadius
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)

        numberLabel.font = Constants.Font.number
        numberLabel.textColor = .label
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(numberLabel)

        descriptionLabel.font = Constants.Font.description
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descriptionLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            gradientBorderView.topAnchor.constraint(equalTo: topAnchor),
            gradientBorderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientBorderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientBorderView.bottomAnchor.constraint(equalTo: bottomAnchor),

            containerView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.borderWidth),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.borderWidth),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.borderWidth),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.borderWidth),

            numberLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.contentTopInset),
            numberLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.contentHorizontalInset),
            numberLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -Constants.contentHorizontalInset),

            descriptionLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: Constants.contentSpacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.contentHorizontalInset),
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -Constants.contentHorizontalInset),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.contentBottomInset)
        ])
    }

    func configure(number: String, description: String) {
        numberLabel.text = number
        descriptionLabel.text = description
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *),
           traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            containerView.backgroundColor = .ypWhite
        }
    }
}
