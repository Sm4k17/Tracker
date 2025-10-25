//
//  String+Localization.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 25.10.2025.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}
