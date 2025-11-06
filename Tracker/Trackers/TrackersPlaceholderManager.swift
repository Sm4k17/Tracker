//
//  TrackersPlaceholderManager.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 03.11.2025.
//

import UIKit

final class TrackersPlaceholderManager {
    
    // MARK: - UI Components
    private let placeholderStackView: UIStackView
    private let placeholderImageView: UIImageView
    private let placeholderLabel: UILabel
    private let collectionView: UICollectionView
    
    // MARK: - Initialization
    init(
        placeholderStackView: UIStackView,
        placeholderImageView: UIImageView,
        placeholderLabel: UILabel,
        collectionView: UICollectionView
    ) {
        self.placeholderStackView = placeholderStackView
        self.placeholderImageView = placeholderImageView
        self.placeholderLabel = placeholderLabel
        self.collectionView = collectionView
    }
    
    // MARK: - Public Methods
    func updatePlaceholderVisibility(
        filteredCategories: [TrackerCategory],
        searchText: String,
        currentFilter: TrackerFilter
    ) {
        let isEmpty = filteredCategories.isEmpty || filteredCategories.allSatisfy { $0.trackers.isEmpty }
        placeholderStackView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        
        if isEmpty {
            if !searchText.isEmpty {
                placeholderLabel.text = R.string.localizable.nothing_found()
                placeholderImageView.image = R.image.icSearchEmpty()
            } else if currentFilter == .completed || currentFilter == .uncompleted {
                placeholderLabel.text = R.string.localizable.nothing_found()
                placeholderImageView.image = R.image.icStatsEmpty() ?? R.image.icDizzy()
            } else {
                placeholderLabel.text = R.string.localizable.what_to_track()
                placeholderImageView.image = R.image.icDizzy()
            }
        }
    }
}
