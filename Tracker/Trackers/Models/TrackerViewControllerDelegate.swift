//
//  TrackerViewControllerDelegate.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 30.09.2025.
//

import Foundation

protocol TrackerViewControllerDelegate: AnyObject {
    func didCreateNewTracker(_ tracker: Tracker)
    func didCancelTrackerCreation()
}
