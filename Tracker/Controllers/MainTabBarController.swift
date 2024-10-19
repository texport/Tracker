//
//  MainTabBarController.swift
//  Tracker
//
//  Created by Sergey Ivanov on 09.09.2024.
//

import UIKit
import YandexMobileMetrica

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackersImage = UIImage(systemName: "record.circle.fill") ?? UIImage()
        let statisticsImage = UIImage(systemName: "hare.fill") ?? UIImage()
        
        let trackersVC = TrackersViewController()
        let trackersNav = UINavigationController(rootViewController: trackersVC)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .mainBackground
        appearance.shadowImage = UIImage()
        appearance.shadowColor = nil
        appearance.titleTextAttributes = [.foregroundColor: UIColor(resource: .mainText)]

        trackersNav.navigationBar.standardAppearance = appearance
        trackersNav.navigationBar.scrollEdgeAppearance = appearance
        trackersNav.navigationBar.compactAppearance = appearance

        trackersNav.navigationBar.isTranslucent = false

        trackersNav.tabBarItem = UITabBarItem(title: NSLocalizedString("tab_trackers", comment: ""), image: trackersImage, tag: 0)
        
        let statisticsVC = StatisticViewController()
        statisticsVC.view.backgroundColor = .mainBackground
        statisticsVC.tabBarItem = UITabBarItem(title: NSLocalizedString("tab_statistics", comment: ""), image: statisticsImage, tag: 1)
        
        viewControllers = [trackersNav, statisticsVC]
        tabBar.backgroundColor = .mainBackground
        tabBar.clipsToBounds = true
        
        tabBar.isTranslucent = false
        
        addTabBarSeparator()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 0 {
            AnalyticsManager.shared.logScreenOpen(screen: "Main")
        } else if item.tag == 1 {
            AnalyticsManager.shared.logScreenOpen(screen: "Statistics")
        }
    }
    
    private func addTabBarSeparator() {
        let separatorHeight: CGFloat = 0.5
        let separator = UIView(frame: CGRect(x: 0, y: 0, width: tabBar.frame.width, height: separatorHeight))
        separator.backgroundColor = .gray
        separator.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        
        tabBar.addSubview(separator)
    }
}
