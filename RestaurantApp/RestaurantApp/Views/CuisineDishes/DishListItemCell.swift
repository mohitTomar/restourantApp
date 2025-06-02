//
//  DishListItemCell.swift
//  RestaurantApp
//
//  Created by Mohit Tomar on 02/06/25.
//

import UIKit

class DishListItemCell: UICollectionViewCell { // Changed from UITableViewCell to UICollectionViewCell
    static let reuseIdentifier = "DishListItemCell"
    
    var onAddToCart: (() -> Void)?

    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = Constants.UI.cornerRadius - 4
        return iv
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.setTitle("Add".localized(), for: .normal)
        button.tintColor = .systemBlue
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        button.layer.cornerRadius = 10
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
        addShadow()

        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(addButton)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -8),

            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            priceLabel.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -8),

            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with dish: Dish) {
        nameLabel.text = dish.name.localized()
        priceLabel.text = "₹\(dish.price)".localized()
        
        if let imageUrl = dish.imageUrl {
            imageView.loadImage(from: imageUrl)
        } else {
            imageView.image = UIImage(systemName: "photo.fill")
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
    }
}
