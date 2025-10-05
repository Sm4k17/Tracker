//
//  CreationTrackerDelegate.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 30.09.2025.
//

import Foundation

protocol CreationTrackerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String) 
    func didCancelCreation()
}
