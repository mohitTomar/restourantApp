//
//  CartViewController.swift
//  RestaurantApp
//
//  Created by Mohit Tomar on 02/06/25.
//

import UIKit
import Combine

class CartViewController: UIViewController {

    private var viewModel = CartViewModel()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(CartItemCell.self, forCellReuseIdentifier: CartItemCell.reuseIdentifier)
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none // Clean look
        tv.allowsSelection = false
        tv.backgroundColor = .clear
        return tv
    }()

    private lazy var totalsStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 8
        sv.distribution = .fillEqually
        sv.backgroundColor = .secondarySystemBackground
        sv.layer.cornerRadius = Constants.UI.cornerRadius
        sv.isLayoutMarginsRelativeArrangement = true
        sv.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
        sv.addShadow()
        return sv
    }()

    private func createTotalRow(title: String, value: String) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing

        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .label
        titleLabel.text = title.localized()

        let valueLabel = UILabel()
        valueLabel.font = UIFont.boldSystemFont(ofSize: 16)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .right
        valueLabel.text = value

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(valueLabel)
        return stack
    }

    private lazy var netTotalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "Net Total: ₹0.00".localized()
        return label
    }()
    private lazy var cgstLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "CGST (2.5%): ₹0.00".localized()
        return label
    }()
    private lazy var sgstLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "SGST (2.5%): ₹0.00".localized()
        return label
    }()
    private lazy var grandTotalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "Grand Total: ₹0.00".localized()
        label.textColor = .systemGreen
        return label
    }()

    private lazy var placeOrderButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Place Order".localized(), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.backgroundColor = .systemRed
        button.tintColor = .white
        button.layer.cornerRadius = Constants.UI.cornerRadius
        button.addTarget(self, action: #selector(placeOrderTapped), for: .touchUpInside)
        button.addShadow()
        return button
    }()
    
    private let activityIndicator = CustomActivityIndicator()
    
    private lazy var emptyCartLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Your cart is empty. Start adding some delicious food!".localized()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true // Initially hidden
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        NotificationCenter.default.addObserver(self, selector: #selector(handleLanguageChange), name: .languageDidChange, object: nil)
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Your Cart".localized()
        navigationController?.navigationBar.prefersLargeTitles = false

        view.addSubview(tableView)
        view.addSubview(totalsStackView)
        view.addSubview(placeOrderButton)
        view.addSubview(emptyCartLabel)

        totalsStackView.addArrangedSubview(createTotalRow(title: "Net Total:", value: "₹0.00"))
        totalsStackView.addArrangedSubview(createTotalRow(title: "CGST (2.5%):", value: "₹0.00"))
        totalsStackView.addArrangedSubview(createTotalRow(title: "SGST (2.5%):", value: "₹0.00"))
        totalsStackView.addArrangedSubview(createTotalRow(title: "Grand Total:", value: "₹0.00"))

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: totalsStackView.topAnchor, constant: -16),

            totalsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            totalsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            totalsStackView.bottomAnchor.constraint(equalTo: placeOrderButton.topAnchor, constant: -20),
            
            placeOrderButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            placeOrderButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            placeOrderButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            placeOrderButton.heightAnchor.constraint(equalToConstant: 50),
            
            emptyCartLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyCartLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            emptyCartLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            emptyCartLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
    }

    // MARK: - ViewModel Binding

    private func bindViewModel() {
        viewModel.$cartItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.updateUIForCartState()
            }
            .store(in: &cancellables)

        viewModel.$netTotal
            .receive(on: DispatchQueue.main)
            .sink { [weak self] total in
                // Corrected: Cast to UILabel to access .text
                if let totalRow = self?.totalsStackView.arrangedSubviews[0] as? UIStackView,
                   let valueLabel = totalRow.arrangedSubviews.last as? UILabel {
                    valueLabel.text = "₹\(String(format: "%.2f", total))"
                }
            }
            .store(in: &cancellables)

        viewModel.$cgstAmount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] amount in
                // Corrected: Cast to UILabel to access .text
                if let cgstRow = self?.totalsStackView.arrangedSubviews[1] as? UIStackView,
                   let valueLabel = cgstRow.arrangedSubviews.last as? UILabel {
                    valueLabel.text = "₹\(String(format: "%.2f", amount))"
                }
            }
            .store(in: &cancellables)

        viewModel.$sgstAmount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] amount in
                // Corrected: Cast to UILabel to access .text
                if let sgstRow = self?.totalsStackView.arrangedSubviews[2] as? UIStackView,
                   let valueLabel = sgstRow.arrangedSubviews.last as? UILabel {
                    valueLabel.text = "₹\(String(format: "%.2f", amount))"
                }
            }
            .store(in: &cancellables)

        viewModel.$grandTotal
            .receive(on: DispatchQueue.main)
            .sink { [weak self] total in
                // Corrected: Cast to UILabel to access .text
                if let grandTotalRow = self?.totalsStackView.arrangedSubviews[3] as? UIStackView,
                   let valueLabel = grandTotalRow.arrangedSubviews.last as? UILabel {
                    valueLabel.text = "₹\(String(format: "%.2f", total))"
                    valueLabel.textColor = .systemGreen // Ensure grand total color is applied
                }
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.activityIndicator.show(on: self!.view) : self?.activityIndicator.hide()
                self?.placeOrderButton.isEnabled = !isLoading // Disable button while loading
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.showAlert(title: "Error", message: message)
                Logger.shared.log("Error displayed on Cart screen: \(message)", level: .error)
            }
            .store(in: &cancellables)

        viewModel.$paymentSuccessMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.showAlert(title: "Order Placed!", message: message) {
                    self?.navigationController?.popToRootViewController(animated: true) // Go back to home
                }
                Logger.shared.log("Payment success message displayed: \(message)", level: .info)
            }
            .store(in: &cancellables)
    }
    
    private func updateUIForCartState() {
        let isCartEmpty = viewModel.cartItems.isEmpty
        tableView.isHidden = isCartEmpty
        totalsStackView.isHidden = isCartEmpty
        placeOrderButton.isHidden = isCartEmpty
        emptyCartLabel.isHidden = !isCartEmpty
        
        placeOrderButton.isEnabled = !isCartEmpty // Disable button if cart is empty
    }
    
    @objc private func handleLanguageChange() {
        title = "Your Cart".localized()

        // Update total labels
        if let label0 = (totalsStackView.arrangedSubviews[0] as? UIStackView)?.arrangedSubviews.first as? UILabel {
            label0.text = "Net Total:".localized()
        }
        if let label1 = (totalsStackView.arrangedSubviews[1] as? UIStackView)?.arrangedSubviews.first as? UILabel {
            label1.text = "CGST (2.5%):".localized()
        }
        if let label2 = (totalsStackView.arrangedSubviews[2] as? UIStackView)?.arrangedSubviews.first as? UILabel {
            label2.text = "SGST (2.5%):".localized()
        }
        if let label3 = (totalsStackView.arrangedSubviews[3] as? UIStackView)?.arrangedSubviews.first as? UILabel {
            label3.text = "Grand Total:".localized()
        }

        // Update other UI
        placeOrderButton.setTitle("Place Order".localized(), for: .normal)
        emptyCartLabel.text = "Your cart is empty. Start adding some delicious food!".localized()
        tableView.reloadData()
    }

    // MARK: - Actions

    @objc private func placeOrderTapped() {
        viewModel.placeOrder()
    }
}

// MARK: - UITableViewDataSource

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cartItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CartItemCell.reuseIdentifier, for: indexPath) as? CartItemCell else {
            return UITableViewCell()
        }
        let cartItem = viewModel.cartItems[indexPath.row]
        cell.configure(with: cartItem)
        
        cell.onQuantityChanged = { [weak self] newQuantity in
            if newQuantity > cartItem.quantity {
                self?.viewModel.addDishToCart(dish: cartItem.dish)
            } else if newQuantity < cartItem.quantity {
                self?.viewModel.removeDishFromCart(dish: cartItem.dish)
            }
            Logger.shared.log("Cart item quantity changed for \(cartItem.dish.name) to \(newQuantity)", level: .debug)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100 // Fixed height for cart item cell
    }
}
