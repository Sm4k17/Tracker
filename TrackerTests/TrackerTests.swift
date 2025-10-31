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
    
    func testOnboardingFirstPage_iPhone11_Light() {
        let page = OnboardingPage(
            image: UIImage(named: "onboardingBlue"),
            titleText: "Отслеживайте только то, что хотите",
            index: 0,
            total: 2
        )
        let vc = OnboardingPageViewController(page: page)
        let traits = UITraitCollection(userInterfaceStyle: .light)
        assertSnapshot(of: vc, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
    
    func testOnboardingFirstPage_iPhone11_Dark() {
        let page = OnboardingPage(
            image: UIImage(named: "onboardingBlue"),
            titleText: "Отслеживайте только то, что хотите",
            index: 0,
            total: 2
        )
        let vc = OnboardingPageViewController(page: page)
        let traits = UITraitCollection(userInterfaceStyle: .dark)
        assertSnapshot(of: vc, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
    
    func testOnboardingSecondPage_iPhone11_Light() {
        let page = OnboardingPage(
            image: UIImage(named: "onboardingRed"),
            titleText: "Даже если это не йога и не вода",
            index: 1,
            total: 2
        )
        let vc = OnboardingPageViewController(page: page)
        let traits = UITraitCollection(userInterfaceStyle: .light)
        assertSnapshot(of: vc, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
    
    func testOnboardingSecondPage_iPhone11_Dark() {
        let page = OnboardingPage(
            image: UIImage(named: "onboardingRed"),
            titleText: "Даже если это не йога и не вода",
            index: 1,
            total: 2
        )
        let vc = OnboardingPageViewController(page: page)
        let traits = UITraitCollection(userInterfaceStyle: .dark)
        assertSnapshot(of: vc, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
    
    func testOnboardingViewController_iPhone11_Light() {
        let vc = OnboardingViewController()
        let traits = UITraitCollection(userInterfaceStyle: .light)
        assertSnapshot(of: vc, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
    
    func testOnboardingViewController_iPhone11_Dark() {
        let vc = OnboardingViewController()
        let traits = UITraitCollection(userInterfaceStyle: .dark)
        assertSnapshot(of: vc, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
    
    // MARK: - Main Flow Tests
    
    func testTrackersViewController_iPhone11_Light() {
        let vc = TrackersViewController()
        let navVC = UINavigationController(rootViewController: vc)
        let traits = UITraitCollection(userInterfaceStyle: .light)
        assertSnapshot(of: navVC, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
    
    func testTrackersViewController_iPhone11_Dark() {
        let vc = TrackersViewController()
        let navVC = UINavigationController(rootViewController: vc)
        let traits = UITraitCollection(userInterfaceStyle: .dark)
        assertSnapshot(of: navVC, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
    
    func testCreationTrackerViewController_iPhone11_Light() {
        let vc = CreationTrackerViewController(delegate: nil)
        let navVC = UINavigationController(rootViewController: vc)
        let traits = UITraitCollection(userInterfaceStyle: .light)
        assertSnapshot(of: navVC, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
    
    func testCreationTrackerViewController_iPhone11_Dark() {
        let vc = CreationTrackerViewController(delegate: nil)
        let navVC = UINavigationController(rootViewController: vc)
        let traits = UITraitCollection(userInterfaceStyle: .dark)
        assertSnapshot(of: navVC, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
    
    // MARK: - Configuration Tests
    
    func testHabitConfigurationViewController_iPhone11_Light() {
        let vc = HabitConfigurationViewController(delegate: nil)
        let navVC = UINavigationController(rootViewController: vc)
        let traits = UITraitCollection(userInterfaceStyle: .light)
        assertSnapshot(of: navVC, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
    
    func testHabitConfigurationViewController_iPhone11_Dark() {
        let vc = HabitConfigurationViewController(delegate: nil)
        let navVC = UINavigationController(rootViewController: vc)
        let traits = UITraitCollection(userInterfaceStyle: .dark)
        assertSnapshot(of: navVC, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
    
    func testEventConfigurationViewController_iPhone11_Light() {
        let vc = EventConfigurationViewController(delegate: nil)
        let navVC = UINavigationController(rootViewController: vc)
        let traits = UITraitCollection(userInterfaceStyle: .light)
        assertSnapshot(of: navVC, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
    
    func testEventConfigurationViewController_iPhone11_Dark() {
        let vc = EventConfigurationViewController(delegate: nil)
        let navVC = UINavigationController(rootViewController: vc)
        let traits = UITraitCollection(userInterfaceStyle: .dark)
        assertSnapshot(of: navVC, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
    
    // MARK: - Selection Screens Tests
    
    func testCategorySelectionViewController_iPhone11_Light() {
        let vc = CategorySelectionViewController(
            selectedCategory: "",
            onCategorySelected: { _ in }
        )
        let navVC = UINavigationController(rootViewController: vc)
        let traits = UITraitCollection(userInterfaceStyle: .light)
        assertSnapshot(of: navVC, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
    
    func testCategorySelectionViewController_iPhone11_Dark() {
        let vc = CategorySelectionViewController(
            selectedCategory: "",
            onCategorySelected: { _ in }
        )
        let navVC = UINavigationController(rootViewController: vc)
        let traits = UITraitCollection(userInterfaceStyle: .dark)
        assertSnapshot(of: navVC, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
    
    func testScheduleSelectionViewController_iPhone11_Light() {
        let vc = ScheduleSelectionViewController(
            selectedDays: [.monday, .wednesday, .friday],
            onScheduleSelected: { _ in }
        )
        let navVC = UINavigationController(rootViewController: vc)
        let traits = UITraitCollection(userInterfaceStyle: .light)
        assertSnapshot(of: navVC, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
    
    func testScheduleSelectionViewController_iPhone11_Dark() {
        let vc = ScheduleSelectionViewController(
            selectedDays: [.monday, .wednesday, .friday],
            onScheduleSelected: { _ in }
        )
        let navVC = UINavigationController(rootViewController: vc)
        let traits = UITraitCollection(userInterfaceStyle: .dark)
        assertSnapshot(of: navVC, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
    
    func testAddCategoryViewController_iPhone11_Light() {
        let vc = AddCategoryViewController(onCategoryCreated: { _ in })
        let navVC = UINavigationController(rootViewController: vc)
        let traits = UITraitCollection(userInterfaceStyle: .light)
        assertSnapshot(of: navVC, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
    
    func testAddCategoryViewController_iPhone11_Dark() {
        let vc = AddCategoryViewController(onCategoryCreated: { _ in })
        let navVC = UINavigationController(rootViewController: vc)
        let traits = UITraitCollection(userInterfaceStyle: .dark)
        assertSnapshot(of: navVC, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
    
    // MARK: - Component Tests
    
    func testEmojiSelectionView_iPhone11_Light() {
        let view = EmojiSelectionView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 414, height: 200))
        let traits = UITraitCollection(userInterfaceStyle: .light)
        assertSnapshot(of: view, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
    
    func testEmojiSelectionView_iPhone11_Dark() {
        let view = EmojiSelectionView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 414, height: 200))
        let traits = UITraitCollection(userInterfaceStyle: .dark)
        assertSnapshot(of: view, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
    
    func testColorSelectionView_iPhone11_Light() {
        let view = ColorSelectionView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 414, height: 200))
        let traits = UITraitCollection(userInterfaceStyle: .light)
        assertSnapshot(of: view, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
    
    func testColorSelectionView_iPhone11_Dark() {
        let view = ColorSelectionView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 414, height: 200))
        let traits = UITraitCollection(userInterfaceStyle: .dark)
        assertSnapshot(of: view, as: .image(size: Self.testSnapshotSize, traits: traits), record: record)
    }
}
