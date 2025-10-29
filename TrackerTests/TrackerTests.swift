//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Рустам Ханахмедов on 29.10.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerSnapshotTests: XCTestCase {
    
    private static let testSnapshotSize = CGSize(width: 414, height: 896) // iPhone 11 size
    
    // - true: для создания референсных скриншотов
    // - false: для проверки против существующих скриншотов
    private let record = false
    
    override class func setUp() {
        super.setUp()
        UserDefaults.standard.set(["ru"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    override func setUp() {
        super.setUp()
        OnboardingStorage.isOnboardingCompleted = false
    }
    
    // MARK: - Onboarding Tests
    
    func testOnboardingFirstPage_iPhone11() {
        let page = OnboardingPage(
            image: UIImage(named: "onboardingBlue"),
            titleText: "Отслеживайте только то, что хотите",
            index: 0,
            total: 2
        )
        let vc = OnboardingPageViewController(page: page)
        assertSnapshot(of: vc, as: .image(size: Self.testSnapshotSize), record: record)
    }
    
    func testOnboardingSecondPage_iPhone11() {
        let page = OnboardingPage(
            image: UIImage(named: "onboardingRed"),
            titleText: "Даже если это не йога и не вода",
            index: 1,
            total: 2
        )
        let vc = OnboardingPageViewController(page: page)
        assertSnapshot(of: vc, as: .image(size: Self.testSnapshotSize), record: record)
    }
    
    func testOnboardingViewController_iPhone11() {
        let vc = OnboardingViewController()
        assertSnapshot(of: vc, as: .image(size: Self.testSnapshotSize), record: record)
    }
    
    // MARK: - Main Flow Tests
    
    func testTrackersViewController_iPhone11() {
        let vc = TrackersViewController()
        let navVC = UINavigationController(rootViewController: vc)
        assertSnapshot(of: navVC, as: .image(size: Self.testSnapshotSize), record: record)
    }
    
    func testCreationTrackerViewController_iPhone11() {
        let vc = CreationTrackerViewController(delegate: nil)
        let navVC = UINavigationController(rootViewController: vc)
        assertSnapshot(of: navVC, as: .image(size: Self.testSnapshotSize), record: record)
    }
    
    // MARK: - Configuration Tests
    
    func testHabitConfigurationViewController_iPhone11() {
        let vc = HabitConfigurationViewController(delegate: nil)
        let navVC = UINavigationController(rootViewController: vc)
        assertSnapshot(of: navVC, as: .image(size: Self.testSnapshotSize), record: record)
    }
    
    func testEventConfigurationViewController_iPhone11() {
        let vc = EventConfigurationViewController(delegate: nil)
        let navVC = UINavigationController(rootViewController: vc)
        assertSnapshot(of: navVC, as: .image(size: Self.testSnapshotSize), record: record)
    }
    
    // MARK: - Selection Screens Tests
    
    func testCategorySelectionViewController_iPhone11() {
        let vc = CategorySelectionViewController(
            selectedCategory: "",
            onCategorySelected: { _ in }
        )
        let navVC = UINavigationController(rootViewController: vc)
        assertSnapshot(of: navVC, as: .image(size: Self.testSnapshotSize), record: record)
    }
    
    func testScheduleSelectionViewController_iPhone11() {
        let vc = ScheduleSelectionViewController(
            selectedDays: [.monday, .wednesday, .friday],
            onScheduleSelected: { _ in }
        )
        let navVC = UINavigationController(rootViewController: vc)
        assertSnapshot(of: navVC, as: .image(size: Self.testSnapshotSize), record: record)
    }
    
    func testAddCategoryViewController_iPhone11() {
        let vc = AddCategoryViewController(onCategoryCreated: { _ in })
        let navVC = UINavigationController(rootViewController: vc)
        assertSnapshot(of: navVC, as: .image(size: Self.testSnapshotSize), record: record)
    }
    
    // MARK: - Component Tests
    
    func testEmojiSelectionView_iPhone11() {
        let view = EmojiSelectionView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 414, height: 200))
        assertSnapshot(of: view, as: .image(size: Self.testSnapshotSize), record: record)
    }
    
    func testColorSelectionView_iPhone11() {
        let view = ColorSelectionView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 414, height: 200))
        assertSnapshot(of: view, as: .image(size: Self.testSnapshotSize), record: record)
    }
}
