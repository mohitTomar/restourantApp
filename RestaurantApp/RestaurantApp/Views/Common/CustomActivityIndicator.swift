//
//  CustomActivityIndicator.swift
//  RestaurantApp
//
//  Created by Mohit Tomar on 02/06/25.
//

import UIKit

class CustomActivityIndicator: UIView {
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.layer.cornerRadius = 10
        visualEffectView.clipsToBounds = true
        return visualEffectView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear // Semi-transparent overlay

        addSubview(blurEffectView)
        blurEffectView.contentView.addSubview(activityIndicator)

        blurEffectView.fillSuperview()

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: blurEffectView.contentView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: blurEffectView.contentView.centerYAnchor).isActive = true

        activityIndicator.color = .darkGray // Or your app's accent color
    }

    func show(on view: UIView) {
        view.addSubview(self)
        self.fillSuperview() // Fills the entire superview

        activityIndicator.startAnimating()
        isHidden = false
        Logger.shared.log("Activity indicator shown.", level: .debug)
    }

    func hide() {
        activityIndicator.stopAnimating()
        isHidden = true
        removeFromSuperview()
        Logger.shared.log("Activity indicator hidden.", level: .debug)
    }
}
