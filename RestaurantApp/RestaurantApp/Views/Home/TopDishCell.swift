//
//  TopDishCell.swift
//  RestaurantApp
//
//  Created by Mohit Tomar on 02/06/25.
//

import UIKit

class TopDishCell: UICollectionViewCell {
    static let reuseIdentifier = "TopDishCell"
    
    var onAddToCart: (() -> Void)?

    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = Constants.UI.cornerRadius
        return iv
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemOrange
        label.textAlignment = .center
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.setTitle("Add".localized(), for: .normal)
        button.tintColor = .systemBlue
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.semanticContentAttribute = .forceRightToLeft // Image on right of title
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = Constants.UI.cornerRadius
        contentView.clipsToBounds = true
        addShadow() // Add shadow to the cell

        let stackView = UIStackView(arrangedSubviews: [imageView, nameLabel, priceLabel, ratingLabel, addButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 8

        contentView.addSubview(stackView)
        stackView.fillSuperview(padding: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        
        // Specific constraints for image view within the stack
        imageView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.9).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.8).isActive = true // Aspect ratio for image
    }

    func configure(with dish: Dish) {
        nameLabel.text = dish.name.localized()
        priceLabel.text = "₹\(dish.price)".localized()
        if let rating = dish.rating, let ratingValue = Double(rating) {
            ratingLabel.text = String(format: "⭐ %.1f", ratingValue)
        } else {
            ratingLabel.text = nil
        }

        if let imageUrl = dish.imageUrl {
            imageView.loadImage(from: imageUrl)
        } else {
            imageView.image = UIImage(systemName: "fork.knife.circle.fill") // Placeholder
            imageView.tintColor = .lightGray
        }
    }
    
    @objc private func addToCartTapped() {
        onAddToCart?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        nameLabel.text = nil
        priceLabel.text = nil
        ratingLabel.text = nil
    }
}
