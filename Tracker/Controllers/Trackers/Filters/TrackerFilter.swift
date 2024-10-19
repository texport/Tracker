//
//  TrackerFilter.swift
//  Tracker
//
//  Created by Sergey Ivanov on 15.10.2024.
//

import UIKit

enum TrackerFilter: String, CaseIterable {
    case all = "Все трекеры"
    case today = "Трекеры на сегодня"
    case completed = "Завершённые"
    case uncompleted = "Незавершённые"
}
