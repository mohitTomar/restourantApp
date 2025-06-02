//
//  CuisineCategoryCell.swift
//  RestaurantApp
//
//  Created by Mohit Tomar on 02/06/25.
//

import UIKit

class CuisineCategoryCell: UICollectionViewCell {
    static let reuseIdentifier = "CuisineCategoryCell"

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
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.6).cgColor]
        gradient.locations = [0.0, 1.0]
        return gradient
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.layer.cornerRadius = Constants.UI.cornerRadius
        contentView.clipsToBounds = true // Clip subviews to rounded corners
        addShadow() // Add shadow to the cell

        contentView.addSubview(imageView)
        imageView.fillSuperview()

        // Add gradient layer
        imageView.layer.addSublayer(gradientLayer)
        
        contentView.addSubview(nameLabel)
        nameLabel.anchor(leading: contentView.leadingAnchor,
                         bottom: contentView.bottomAnchor,
                         trailing: contentView.trailingAnchor,
                         padding: UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = imageView.bounds
    }

    func configure(with cuisine: Cuisine) {
        nameLabel.text = cuisine.cuisineName.localized()
        if let imageUrl = cuisine.cuisineImageUrl {
            imageView.loadImage(from: imageUrl)
        } else {
            imageView.image = UIImage(systemName: "photo.fill") // Placeholder
            imageView.tintColor = .lightGray
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        nameLabel.text = nil
    }
}
