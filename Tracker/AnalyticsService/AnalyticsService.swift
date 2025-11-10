//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 02.11.2025.
//

import Foundation
import AppMetricaCore

// Протокол для облегчения тестирования (опционально, но очень рекомендуется)
protocol AnalyticsReporter {
    func report(event: String, params: [AnyHashable: Any])
}

struct AnalyticsService: AnalyticsReporter {
    static let shared = AnalyticsService()
    
    private init() {} // Запрещаем создание экземпляров
    
    // Приватная инициализация, гарантирующая, что она произойдет только один раз
    static func activate() {
        // Используем ключ только здесь, чтобы не было дублирования
        guard let configuration = AppMetricaConfiguration(apiKey: "292b5588-21a0-45b8-81cf-bfb83961f0e2") else { return }
        AppMetrica.activate(with: configuration)
    }
    
    // Функция для отправки событий
    func report(event: String, params: [AnyHashable: Any]) {
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
