//
//  ScheduleSelectionViewController.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 30.09.2025.
//

import UIKit

// MARK: - Schedule Selection View Controller
final class ScheduleSelectionViewController: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let navigationTitle = "Расписание"
        static let readyButtonTitle = "Готово"
        
        enum Layout {
            static let horizontalInset: CGFloat = 16
            static let rowHeight: CGFloat = 75
            static let buttonHeight: CGFloat = 60
            static let cornerRadius: CGFloat = 16
            static let tableViewTopInset: CGFloat = 24
            static let buttonBottomInset: CGFloat = 24
        }
        
        enum Fonts {
            static let button: UIFont = .systemFont(ofSize: 16, weight: .medium)
        }
        
        enum Colors {
            static let buttonText: UIColor = .ypWhite
        }
    }
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(ScheduleCell.self, forCellReuseIdentifier: "ScheduleCell")
        table.backgroundColor = .ypWhite
        table.separatorStyle = .singleLine
        table.layer.cornerRadius = Constants.Layout.cornerRadius
        table.layer.masksToBounds = true
        table.isScrollEnabled = false
        return table
    }()
    
    private lazy var readyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.readyButtonTitle, for: .normal)
        button.titleLabel?.font = Constants.Fonts.button
        button.backgroundColor = .ypBlack
        button.setTitleColor(Constants.Colors.buttonText, for: .normal)
        button.layer.cornerRadius = Constants.Layout.cornerRadius
        button.layer.masksToBounds = true
        button.heightAnchor.constraint(equalToConstant: Constants.Layout.buttonHeight).isActive = true
        
        button.addAction(UIAction { [weak self] _ in
            self?.didTapReadyButton()
        }, for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Properties
    private let selectedDays: Set<Week>
    private let onScheduleSelected: (Set<Week>) -> Void
    private var currentSelectedDays: Set<Week>
    
    // MARK: - Initializer
    init(selectedDays: Set<Week>, onScheduleSelected: @escaping (Set<Week>) -> Void) {
        self.selectedDays = selectedDays
        self.currentSelectedDays = selectedDays
        self.onScheduleSelected = onScheduleSelected
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .ypWhite
        setupNavigationBar()
        setupViews()
        setupConstraints()
        setupAutoresizingMasks()
    }
    
    private func setupNavigationBar() {
        title = Constants.navigationTitle
        // Убираем кнопку назад
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
    }
    
    private func setupViews() {
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        view.addSubview(readyButton)
    }
    
    private func setupAutoresizingMasks() {
        [tableView, readyButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        setupTableViewConstraints()
        setupReadyButtonConstraints()
    }
    
    private func setupTableViewConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Layout.tableViewTopInset),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.horizontalInset),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.horizontalInset),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(Week.allCases.count) * Constants.Layout.rowHeight)
        ])
    }
    
    private func setupReadyButtonConstraints() {
        NSLayoutConstraint.activate([
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.horizontalInset),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.horizontalInset),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Layout.buttonBottomInset)
        ])
    }
    
    // MARK: - Actions
    private func didTapReadyButton() {
        onScheduleSelected(currentSelectedDays)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ScheduleSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Week.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCell
        let day = Week.allCases[indexPath.row]
        let isSelected = currentSelectedDays.contains(day)
        cell.configure(with: day.title, isSelected: isSelected) { [weak self] isOn in
            self?.toggleDaySelection(day, isSelected: isOn)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Layout.rowHeight
    }
    
    private func toggleDaySelection(_ day: Week, isSelected: Bool) {
        if isSelected {
            currentSelectedDays.insert(day)
        } else {
            currentSelectedDays.remove(day)
        }
    }
}

// MARK: - UITableViewDelegate
extension ScheduleSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as? ScheduleCell
        cell?.toggleSwitch()
    }
}

// MARK: - ScheduleCell
private final class ScheduleCell: UITableViewCell {
    
    // MARK: - Constants
    private enum CellConstants {
        enum Fonts {
            static let cellTitle: UIFont = .systemFont(ofSize: 16, weight: .regular)
        }
        
        enum Colors {
            static let switchTint: UIColor = .ypBlue
        }
    }
    
    // MARK: - UI Components
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = CellConstants.Fonts.cellTitle
        return label
    }()
    
    private lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = CellConstants.Colors.switchTint
        switchControl.addAction(UIAction { [weak self] _ in
            self?.switchValueChanged()
        }, for: .valueChanged)
        return switchControl
    }()
    
    // MARK: - Properties
    private var switchValueChangedHandler: ((Bool) -> Void)?
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        setupViews()
        setupConstraints()
        setupAutoresizingMasks()
    }
    
    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchControl)
    }
    
    private func setupAutoresizingMasks() {
        [titleLabel, switchControl].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: - Configuration
    func configure(with title: String, isSelected: Bool, onSwitchValueChanged: @escaping (Bool) -> Void) {
        titleLabel.text = title
        switchControl.isOn = isSelected
        self.switchValueChangedHandler = onSwitchValueChanged
    }
    
    func toggleSwitch() {
        switchControl.isOn.toggle()
        switchValueChanged()
    }
    
    private func switchValueChanged() {
        switchValueChangedHandler?(switchControl.isOn)
    }
}
