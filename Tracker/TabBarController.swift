//
//  TabBarController.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 15.09.2025.
//

import UIKit

// MARK: - Constants
private enum TabBarConstants {
    enum Images {
        static let trackers = "record.circle.fill"
        static let stats = "hare.fill"
    }
    
    enum TabBar {
        static let tintColor: UIColor = .ypBlue
        static let unselectedTintColor: UIColor = .ypGray
        static let backgroundColor: UIColor = .ypWhite
        static let isTranslucent: Bool = false
    }
    
    enum Titles {
        static let trackers = "Трекеры"
        static let stats = "Статистика"
    }
}

final class TabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTabBar()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = TabBarConstants.TabBar.backgroundColor
        tabBar.barTintColor = TabBarConstants.TabBar.backgroundColor
        tabBar.tintColor = TabBarConstants.TabBar.tintColor
        tabBar.unselectedItemTintColor = TabBarConstants.TabBar.unselectedTintColor
        tabBar.isTranslucent = TabBarConstants.TabBar.isTranslucent
        
        // Удаление верхней границы и теней
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        
        // Добавляем собственную верхнюю границу
        let topBorder = UIView()
        topBorder.backgroundColor = .ypGray
        topBorder.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(topBorder)
        
        NSLayoutConstraint.activate([
            topBorder.topAnchor.constraint(equalTo: tabBar.topAnchor),
            topBorder.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            topBorder.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            topBorder.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func setupTabBar() {
        guard let trackersImage = UIImage(systemName: TabBarConstants.Images.trackers),
              let statsImage = UIImage(systemName: TabBarConstants.Images.stats) else {
            print("Missing SF Symbols. Проверьте названия иконок.")
            return
        }
        
        let trackersVC = createTrackersViewController()
        let statsVC = createStatsViewController()
        
        trackersVC.tabBarItem = UITabBarItem(
            title: TabBarConstants.Titles.trackers,
            image: trackersImage,
            selectedImage: nil
        )
        
        statsVC.tabBarItem = UITabBarItem(
            title: TabBarConstants.Titles.stats,
            image: statsImage,
            selectedImage: nil
        )
        
        // Настройка отступов через UIAppearance
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
        
        viewControllers = [trackersVC, statsVC]
    }
    
    // MARK: - View Controller Factory Methods
    private func createTrackersViewController() -> UINavigationController {
        let trackersViewController = TrackersViewController()
        let navigationController = UINavigationController(rootViewController: trackersViewController)
        return navigationController
    }

    private func createStatsViewController() -> UINavigationController {
        let statsViewController = StatisticViewController()
        let navigationController = UINavigationController(rootViewController: statsViewController)
        return navigationController
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview("TabController") {
    TabBarController()
}
#endif
