//
//  CartItemCell.swift
//  RestaurantApp
//
//  Created by Mohit Tomar on 02/06/25.
//

import UIKit

class CartItemCell: UITableViewCell {
    static let reuseIdentifier = "CartItemCell"
    
    var onQuantityChanged: ((Int) -> Void)?

    private var currentCartItem: CartItem?

    private lazy var dishImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = Constants.UI.cornerRadius - 4
        return iv
    }()

    private lazy var dishNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()

    private lazy var dishPriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var quantityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private lazy var quantityStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.minimumValue = 1
        stepper.maximumValue = 99 // Arbitrary max quantity
        stepper.addTarget(self, action: #selector(quantityStepperValueChanged), for: .valueChanged)
        return stepper
    }()
    
    private lazy var totalPriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .systemGreen
        label.textAlignment = .right
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = Constants.UI.cornerRadius
        contentView.clipsToBounds = true
        addShadow()
        
        // Add a padding view to give space between cells
        let paddingView = UIView()
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(paddingView)
        NSLayoutConstraint.activate([
            paddingView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            paddingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            paddingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            paddingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        paddingView.addSubview(dishImageView)
        paddingView.addSubview(dishNameLabel)
        paddingView.addSubview(dishPriceLabel)
        paddingView.addSubview(quantityLabel)
        paddingView.addSubview(quantityStepper)
        paddingView.addSubview(totalPriceLabel)

        NSLayoutConstraint.activate([
            dishImageView.leadingAnchor.constraint(equalTo: paddingView.leadingAnchor),
            dishImageView.centerYAnchor.constraint(equalTo: paddingView.centerYAnchor),
            dishImageView.widthAnchor.constraint(equalToConstant: 70),
            dishImageView.heightAnchor.constraint(equalToConstant: 70),

            dishNameLabel.topAnchor.constraint(equalTo: dishImageView.topAnchor, constant: 2),
            dishNameLabel.leadingAnchor.constraint(equalTo: dishImageView.trailingAnchor, constant: 12),
            dishNameLabel.trailingAnchor.constraint(equalTo: quantityStepper.leadingAnchor, constant: -8),

            dishPriceLabel.topAnchor.constraint(equalTo: dishNameLabel.bottomAnchor, constant: 4),
            dishPriceLabel.leadingAnchor.constraint(equalTo: dishImageView.trailingAnchor, constant: 12),
            dishPriceLabel.trailingAnchor.constraint(equalTo: quantityStepper.leadingAnchor, constant: -8),
            
            quantityStepper.trailingAnchor.constraint(equalTo: paddingView.trailingAnchor),
            quantityStepper.topAnchor.constraint(equalTo: dishNameLabel.topAnchor),
            
            quantityLabel.trailingAnchor.constraint(equalTo: quantityStepper.leadingAnchor, constant: -8),
            quantityLabel.centerYAnchor.constraint(equalTo: quantityStepper.centerYAnchor),
            quantityLabel.widthAnchor.constraint(equalToConstant: 30), // Fixed width for quantity number
            
            totalPriceLabel.trailingAnchor.constraint(equalTo: paddingView.trailingAnchor),
            totalPriceLabel.bottomAnchor.constraint(equalTo: dishImageView.bottomAnchor)
        ])
    }

    func configure(with item: CartItem) {
        currentCartItem = item
        dishNameLabel.text = item.dish.name.localized()
        dishPriceLabel.text = "₹\(item.dish.price)".localized()
        quantityLabel.text = "\(item.quantity)"
        quantityStepper.value = Double(item.quantity)
        totalPriceLabel.text = "₹\(String(format: "%.2f", item.totalPrice))".localized()
        
        if let imageUrl = item.dish.imageUrl {
            dishImageView.loadImage(from: imageUrl)
        } else {
            dishImageView.image = UIImage(systemName: "photo.fill")
            dishImageView.tintColor = .lightGray
        }
    }
    
    @objc private func quantityStepperValueChanged() {
        let newQuantity = Int(quantityStepper.value)
        quantityLabel.text = "\(newQuantity)"
        onQuantityChanged?(newQuantity)
        
        // Re-calculate and display total price for this item
        if let item = currentCartItem {
            let newTotalPrice = (Double(item.dish.price) ?? 0.0) * Double(newQuantity)
            totalPriceLabel.text = "₹\(String(format: "%.2f", newTotalPrice))".localized()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dishImageView.image = nil
        dishNameLabel.text = nil
        dishPriceLabel.text = nil
        quantityLabel.text = nil
        totalPriceLabel.text = nil
        currentCartItem = nil
        quantityStepper.value = 1
    }
}
