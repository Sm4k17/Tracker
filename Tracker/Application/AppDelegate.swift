//
//  AppDelegate.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 08.09.2025.
//

import UIKit
import AppMetricaCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Инициализируем все сервисы здесь
        AnalyticsService.activate() // <- Вся логика здесь
        
        return true
    }
}

