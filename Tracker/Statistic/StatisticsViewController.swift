//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 15.09.2025.
//

import UIKit

final class StatisticsViewController: UIViewController {

    // MARK: - Constants
    private enum Constants {
        static let navigationTitle = "Статистика"
        static let placeholderTitle = "Анализировать пока нечего"
        static let placeholderImageName = "statisticsError"

        enum Layout {
            static let titleTopInset: CGFloat = 24
            static let titleHorizontalInset: CGFloat = 16
            static let scrollViewTopOffset: CGFloat = 24
            static let cardsStackTopOffset: CGFloat = 12
            static let cardsStackBottomInset: CGFloat = 12
            static let cardHeight: CGFloat = 90
            static let cardSpacing: CGFloat = 12
            static let horizontalPadding: CGFloat = 16

            static let placeholderImageSize: CGFloat = 80
            static let placeholderLabelTopOffset: CGFloat = 8
            static let placeholderLabelHorizontalInset: CGFloat = 16
        }

        enum Text {
            static let bestPeriod = "Лучший период"
            static let idealDays = "Идеальные дни"
            static let completedTrackers = "Трекеров завершено"
            static let averageValue = "Среднее значение"
        }
    }

    // MARK: - UI
    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.text = Constants.navigationTitle
        l.font = .systemFont(ofSize: 34, weight: .bold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.showsVerticalScrollIndicator = false
        return v
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let cardsStackView: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = Constants.Layout.cardSpacing
        s.distribution = .fill
        s.alignment = .fill
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let bestPeriodCard = StatisticCard()
    private let idealDaysCard = StatisticCard()
    private let completedTrackersCard = StatisticCard()
    private let averageValueCard = StatisticCard()

    // Empty State
    private let emptyStateView = UIView()
    private let emptyStateImageView = UIImageView()
    private let emptyStateLabel = UILabel()

    // MARK: - Services
    private let statisticsDataStore: StatisticsDataStore

    // MARK: - Init
    init(statisticsDataStore: StatisticsDataStore = StatisticsDataStore()) {
        self.statisticsDataStore = statisticsDataStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        statisticsDataStore.delegate = self
        statisticsDataStore.refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statisticsDataStore.refresh()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .ypWhite

        // cards
        cardsStackView.addArrangedSubview(bestPeriodCard)
        cardsStackView.addArrangedSubview(idealDaysCard)
        cardsStackView.addArrangedSubview(completedTrackersCard)
        cardsStackView.addArrangedSubview(averageValueCard)

        // empty state
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true

        emptyStateImageView.image = UIImage(named: Constants.placeholderImageName)
        emptyStateImageView.contentMode = .scaleAspectFit
        emptyStateImageView.translatesAutoresizingMaskIntoConstraints = false

        emptyStateLabel.text = Constants.placeholderTitle
        emptyStateLabel.font = .systemFont(ofSize: 12)
        emptyStateLabel.textColor = .label
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false

        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)

        // hierarchy
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(cardsStackView)
        view.addSubview(emptyStateView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Layout.titleTopInset),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.titleHorizontalInset),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.titleHorizontalInset),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.Layout.scrollViewTopOffset),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            cardsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Layout.cardsStackTopOffset),
            cardsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.horizontalPadding),
            cardsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.horizontalPadding),
            cardsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Layout.cardsStackBottomInset),

            bestPeriodCard.heightAnchor.constraint(equalToConstant: Constants.Layout.cardHeight),
            idealDaysCard.heightAnchor.constraint(equalToConstant: Constants.Layout.cardHeight),
            completedTrackersCard.heightAnchor.constraint(equalToConstant: Constants.Layout.cardHeight),
            averageValueCard.heightAnchor.constraint(equalToConstant: Constants.Layout.cardHeight),

            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: Constants.Layout.placeholderImageSize),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: Constants.Layout.placeholderImageSize),

            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: Constants.Layout.placeholderLabelTopOffset),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: Constants.Layout.placeholderLabelHorizontalInset),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -Constants.Layout.placeholderLabelHorizontalInset),
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }

    // MARK: - UI Update
    private func updateUI(with statistics: TrackerStatistics?) {
        let hasData = (statistics != nil)
        emptyStateView.isHidden = hasData
        cardsStackView.isHidden = !hasData

        guard let s = statistics else { return }

        bestPeriodCard.configure(number: "\(s.bestPeriod)", description: Constants.Text.bestPeriod)
        idealDaysCard.configure(number: "\(s.idealDays)", description: Constants.Text.idealDays)
        completedTrackersCard.configure(number: "\(s.totalCompleted)", description: Constants.Text.completedTrackers)
        averageValueCard.configure(number: String(format: "%.1f", s.averageValue), description: Constants.Text.averageValue)
    }
}

// MARK: - StatisticsDataStoreDelegate
extension StatisticsViewController: StatisticsDataStoreDelegate {
    func statisticsDataStore(_ store: StatisticsDataStore, didUpdate statistics: TrackerStatistics?) {
        updateUI(with: statistics)
    }
}
