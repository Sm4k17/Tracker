//
//  TrackersLayoutCalculator.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 03.11.2025.
//

import UIKit

final class TrackersLayoutCalculator {
    
    // MARK: - Constants
    enum Constants {
        static let collectionItemSpacing: CGFloat = 12
        static let collectionLineSpacing: CGFloat = 16
        static let collectionSectionInsetTop: CGFloat = 12
        static let collectionSectionInsetLeft: CGFloat = 16
        static let collectionSectionInsetBottom: CGFloat = 16
        static let collectionSectionInsetRight: CGFloat = 16
        static let collectionItemHeight: CGFloat = 148
        static let collectionHeaderHeight: CGFloat = 18
        static let collectionItemsPerRow: CGFloat = 2
        
        static var collectionTotalHorizontalInset: CGFloat {
            collectionSectionInsetLeft + collectionSectionInsetRight + collectionItemSpacing
        }
    }
    
    // MARK: - Public Methods
    static func calculateCollectionViewItemSize(for view: UIView) -> CGSize {
        let totalWidth = view.bounds.width - Constants.collectionTotalHorizontalInset
        let itemWidth = totalWidth / Constants.collectionItemsPerRow
        
        return CGSize(
            width: itemWidth,
            height: Constants.collectionItemHeight
        )
    }
    
    static func createCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = Constants.collectionItemSpacing
        layout.minimumLineSpacing = Constants.collectionLineSpacing
        layout.sectionInset = UIEdgeInsets(
            top: Constants.collectionSectionInsetTop,
            left: Constants.collectionSectionInsetLeft,
            bottom: Constants.collectionSectionInsetBottom,
            right: Constants.collectionSectionInsetRight
        )
        return layout
    }
    
    static func referenceSizeForHeader() -> CGSize {
        return CGSize(width: 0, height: Constants.collectionHeaderHeight)
    }
}
