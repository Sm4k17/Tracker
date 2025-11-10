//
//  TrackerCellDelegate.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 03.11.2025.
//

import Foundation

protocol TrackerCellDelegate: AnyObject {
    func didTapPlusButton(in cell: TrackerCollectionViewCell)
    func didTogglePin(for trackerId: UUID)
    func didRequestEdit(for trackerId: UUID)
    func didRequestDelete(for trackerId: UUID)
}
