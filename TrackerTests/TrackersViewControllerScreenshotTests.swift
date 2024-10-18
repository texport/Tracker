//
//  TrackersViewControllerScreenshotTests.swift
//  Tracker
//
//  Created by Sergey Ivanov on 16.10.2024.
//
import XCTest
import SnapshotTesting
@testable import Tracker

final class MainTabBarControllerSnapshotTests: XCTestCase {

    // Тест для светлой темы
    func testTrackersScreenLight() throws {
        let vc = MainTabBarController()
        vc.loadViewIfNeeded()

        // Создаем ожидание, чтобы дождаться завершения прокрутки
        let expectation = XCTestExpectation(description: "Waiting for scroll to complete")

        // Имитация прокрутки (если требуется) или любых других действий
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {  // Установите время задержки, чтобы дождаться завершения всех анимаций
            expectation.fulfill()  // Сообщаем, что ожидание завершено
        }

        // Ждем завершения анимации прокрутки
        wait(for: [expectation], timeout: 2.0)  // Установите время таймаута больше времени задержки

        // Делаем скриншот после выполнения всех действий
        assertSnapshot(matching: vc, as: .image(on: .iPhone13ProMax, traits: .init(userInterfaceStyle: .light)))
    }

    // Тест для тёмной темы
    func testTrackersScreenDark() throws {
        let vc = MainTabBarController()
        vc.loadViewIfNeeded()

        let expectation = XCTestExpectation(description: "Waiting for scroll to complete")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)

        assertSnapshot(matching: vc, as: .image(on: .iPhone13ProMax, traits: .init(userInterfaceStyle: .dark)))
    }
}
