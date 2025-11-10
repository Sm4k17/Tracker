//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 19.10.2025.
//

import UIKit

// MARK: - Onboarding View Controller
final class OnboardingViewController: UIPageViewController {
    
    private var isPageControlAdded = false
    
    // MARK: - Constants
    private enum Constants {
        static let bottomOffset: CGFloat = 134
        
        // Статические цвета для онбординга
        static let backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        static let pageControlCurrentColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1)
        static let pageControlDefaultColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 0.3)
        
        enum OnboardingStep: Int, CaseIterable {
            case blue
            case red
            
            var image: UIImage? {
                switch self {
                case .blue:
                    return R.image.onboardingBlue()
                case .red:
                    return R.image.onboardingRed()
                }
            }
            
            var titleText: String {
                switch self {
                case .blue:
                    return R.string.localizable.track_only_what_you_want()
                case .red:
                    return R.string.localizable.even_if_not_water_and_yoga()
                }
            }
            
            var page: OnboardingPage {
                return OnboardingPage(
                    image: image,
                    titleText: titleText,
                    index: rawValue,
                    total: OnboardingStep.allCases.count
                )
            }
        }
    }
    
    // MARK: - UI Components
    private lazy var pages: [OnboardingPageViewController] = {
        Constants.OnboardingStep.allCases.map { step in
            OnboardingPageViewController(page: step.page)
        }
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = Constants.pageControlCurrentColor
        pageControl.pageIndicatorTintColor = Constants.pageControlDefaultColor
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupInitialPage()
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !isPageControlAdded {
            setupPageControlIfNeeded()
            isPageControlAdded = true
        }
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = Constants.backgroundColor
        setupDataSourceAndDelegate()
    }
    
    private func setupDataSourceAndDelegate() {
        dataSource = self
        delegate = self
    }
    
    private func setupPageControlIfNeeded() {
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -Constants.bottomOffset)
        ])
        
        view.bringSubviewToFront(pageControl)
        
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
    }
    
    private func setupInitialPage() {
        guard let firstPage = pages.first else { return }
        setViewControllers([firstPage], direction: .forward, animated: false)
    }
    
    // MARK: - Actions
    @objc private func pageControlTapped(_ sender: UIPageControl) {
        let newIndex = sender.currentPage
        guard
            let currentViewController = viewControllers?.first as? OnboardingPageViewController,
            let currentIndex = pages.firstIndex(of: currentViewController)
        else { return }
        
        let direction: UIPageViewController.NavigationDirection = newIndex > currentIndex ? .forward : .reverse
        
        sender.isEnabled = false
        
        setViewControllers([pages[newIndex]], direction: direction, animated: true) { [weak self] _ in
            guard let self = self else { return }
            self.pageControl.currentPage = newIndex
            sender.isEnabled = true
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let onboardingViewController = viewController as? OnboardingPageViewController,
            let currentIndex = pages.firstIndex(of: onboardingViewController),
            currentIndex > 0
        else {
            return nil
        }
        
        return pages[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let onboardingViewController = viewController as? OnboardingPageViewController,
            let currentIndex = pages.firstIndex(of: onboardingViewController),
            currentIndex < pages.count - 1
        else {
            return nil
        }
        
        return pages[currentIndex + 1]
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed,
              let currentViewController = viewControllers?.first as? OnboardingPageViewController,
              let currentIndex = pages.firstIndex(of: currentViewController)
        else { return }
        
        pageControl.currentPage = currentIndex
    }
}
