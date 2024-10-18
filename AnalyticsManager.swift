//
//  AnalyticsManager.swift
//  Tracker
//
//  Created by Sergey Ivanov on 17.10.2024.
//
import YandexMobileMetrica
import UIKit

final class AnalyticsManager {
    
    // MARK: - Singleton Instance
    static let shared = AnalyticsManager()
    
    private init() {}
    
    // MARK: - Общий метод для логирования событий
    private func logEvent(event: String, screen: String, item: String? = nil) {
        var parameters: [String: Any] = [
            "event": event,
            "screen": screen
        ]
        
        if let item = item {
            parameters["item"] = item
        }
        
        // Отправка события в Яндекс.Метрику
        YMMYandexMetrica.reportEvent("event", parameters: parameters) { error in
            if let error = error as NSError? {
                print("Ошибка отправки события: \(error.localizedDescription)")
            } else {
                print("Событие успешно отправлено: \(parameters)")
            }
        }
    }
    
    // MARK: - Методы для логирования открытия/закрытия экрана
    
    func logScreenOpen(screen: String) {
        logEvent(event: "open", screen: screen)
    }
    
    func logScreenClose(screen: String) {
        logEvent(event: "close", screen: screen)
    }
    
    // MARK: - Методы для логирования кликов по элементам
    
    func logAddTrackClick(screen: String) {
        logEvent(event: "click", screen: screen, item: "add_track")
    }
    
    func logTrackCompletionClick(screen: String) {
        logEvent(event: "click", screen: screen, item: "track")
    }
    
    func logFilterClick(screen: String) {
        logEvent(event: "click", screen: screen, item: "filter")
    }
    
    func logEditClick(screen: String) {
        logEvent(event: "click", screen: screen, item: "edit")
    }
    
    func logDeleteClick(screen: String) {
        logEvent(event: "click", screen: screen, item: "delete")
    }
}
