//
//  FilterViewModel.swift
//  Tracker
//
//  Created by Sergey Ivanov on 15.10.2024.
//

import UIKit

final class FilterViewModel {
    var selectedFilter: TrackerFilter
    var onFilterSelected: ((TrackerFilter) -> Void)?

    init(selectedFilter: TrackerFilter) {
        self.selectedFilter = selectedFilter
    }

    func selectFilter(_ filter: TrackerFilter) {
        selectedFilter = filter
        onFilterSelected?(filter)
    }
}
