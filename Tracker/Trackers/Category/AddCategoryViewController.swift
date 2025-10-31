//
//  AddCategoryViewController.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 30.09.2025.
//

import UIKit

final class AddCategoryViewController: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let navigationTitle = R.string.localizable.new_category()
        static let textFieldPlaceholder = R.string.localizable.enter_category_name()
        static let readyButtonTitle = R.string.localizable.ready()
        
        enum Layout {
            static let horizontalInset: CGFloat = 16
            static let topInset: CGFloat = 24
        }
    }
    
    // MARK: - UI Components
    private lazy var categoryTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.textFieldPlaceholder
        textField.backgroundColor = .ypBackground
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        // Добавляем обработку изменений текста
        textField.addAction(UIAction { [weak self] _ in
            self?.updateReadyButtonState()
        }, for: .editingChanged)
        
        return textField
    }()
    
    private lazy var readyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.readyButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGray
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        button.addAction(UIAction { [weak self] _ in
            self?.didTapReadyButton()
        }, for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Properties
    private let onCategoryCreated: (String) -> Void
    
    // MARK: - Initializer
    init(onCategoryCreated: @escaping (String) -> Void) {
        self.onCategoryCreated = onCategoryCreated
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTapGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        categoryTextField.becomeFirstResponder() // Автофокус на поле ввода
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .ypWhite
        setupNavigationBar()
        setupViews()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        title = Constants.navigationTitle
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = nil
    }
    
    private func setupViews() {
        view.addSubview(categoryTextField)
        view.addSubview(readyButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            categoryTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Layout.topInset),
            categoryTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.horizontalInset),
            categoryTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.horizontalInset),
            
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.horizontalInset),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.horizontalInset),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func handleTap() {
        view.endEditing(true)
    }
    
    private func didTapReadyButton() {
        createCategory()
    }
    
    private func createCategory() {
        guard let categoryName = categoryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !categoryName.isEmpty else {
            return
        }
        
        // Вызываем колбэк и возвращаемся назад со стандартной анимацией
        onCategoryCreated(categoryName)
        navigationController?.popViewController(animated: true)
    }
    
    private func updateReadyButtonState() {
        let text = categoryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let isEmpty = text.isEmpty
        
        readyButton.isEnabled = !isEmpty
        readyButton.backgroundColor = isEmpty ? .ypGray : .ypBlack
    }
}
