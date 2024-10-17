//
//  TrackersViewControllerUnitTests.swift
//  Tracker
//
//  Created by Sergey Ivanov on 16.10.2024.
//
import XCTest
@testable import Tracker

final class TrackersViewControllerUnitTests: XCTestCase {

    var viewController: TrackersViewController!

    override func setUpWithError() throws {
        // Инициализируем контроллер перед каждым тестом
        viewController = TrackersViewController()
        viewController.loadViewIfNeeded() // Загружаем view
    }

    override func tearDownWithError() throws {
        // Обнуляем контроллер после каждого теста
        viewController = nil
    }

    // Пример теста для проверки, что контроллер существует
    func testViewControllerIsNotNil() throws {
        XCTAssertNotNil(viewController, "Контроллер должен быть инициализирован")
    }

    // Пример теста для проверки, что вью контроллера загружена
    func testViewIsLoaded() throws {
        XCTAssertNotNil(viewController.view, "View контроллера должна быть загружена")
    }
    
    // Пример теста для проверки, что дата выбрана верно
    func testDatePickerDateIsToday() throws {
        let today = Calendar.current.startOfDay(for: Date())
        XCTAssertEqual(viewController.datePicker.date, today, "DatePicker должен быть установлен на текущую дату")
    }
}
