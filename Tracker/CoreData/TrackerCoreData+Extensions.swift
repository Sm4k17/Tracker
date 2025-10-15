//
//  TrackerCoreData+Extensions.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 14.10.2025.
//

import UIKit

extension TrackerCoreData {
    
    // MARK: - Color Handling
    func getColor() -> UIColor? {
        guard let colorData = colorTrackers else {
            return nil
        }
        
        do {
            if let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
                return color
            }
        } catch {
            print("❌ Error unarchiving color: \(error)")
        }
        return nil
    }
    
    func setColor(_ color: UIColor) {
        do {
            let colorData = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
            colorTrackers = colorData
        } catch {
            print("❌ Error archiving color: \(error)")
        }
    }
    
    // MARK: - Schedule Handling
    func getSchedule() -> Set<Week> {
        guard let scheduleData = scheduleTrackers else { return [] }
        
        do {
            if #available(iOS 11.0, *) {
                let allowedClasses: [AnyClass] = [NSArray.self, NSNumber.self]
                if let scheduleArray = try NSKeyedUnarchiver.unarchivedObject(ofClasses: allowedClasses, from: scheduleData) as? [Int] {
                    return Set(scheduleArray.compactMap { Week(rawValue: $0) })
                }
            } else {
                if let scheduleArray = NSKeyedUnarchiver.unarchiveObject(with: scheduleData) as? [Int] {
                    return Set(scheduleArray.compactMap { Week(rawValue: $0) })
                }
            }
        } catch {
            print("❌ Error unarchiving schedule: \(error)")
        }
        return []
    }
    
    func setSchedule(_ schedule: Set<Week>) {
        let scheduleArray = schedule.map { $0.rawValue }
        
        do {
            if #available(iOS 11.0, *) {
                let scheduleData = try NSKeyedArchiver.archivedData(withRootObject: scheduleArray, requiringSecureCoding: false)
                scheduleTrackers = scheduleData
            } else {
                let scheduleData = NSKeyedArchiver.archivedData(withRootObject: scheduleArray)
                scheduleTrackers = scheduleData
            }
        } catch {
            print("❌ Error archiving schedule: \(error)")
        }
    }
}
