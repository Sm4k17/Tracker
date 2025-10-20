//
//  OnboardingStorage.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 19.10.2025.
//

import Foundation

// MARK: - Onboarding Storage
final class OnboardingStorage {
    
    private enum Keys {
        static let onboardingCompleted = "onboardingCompleted"
    }
    
    static var isOnboardingCompleted: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.onboardingCompleted)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.onboardingCompleted)
        }
    }
}
