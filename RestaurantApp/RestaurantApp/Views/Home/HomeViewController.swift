//
//  HomeViewController.swift
//  RestaurantApp
//
//  Created by Mohit Tomar on 02/06/25.
//

import UIKit
import Combine

class HomeViewController: UIViewController {

    private var viewModel = HomeViewModel()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var cuisineCategoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.text = "Cuisine Categories".localized()
        return label
    }()

    private lazy var cuisineCategoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16 // Spacing between cards
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(CuisineCategoryCell.self, forCellWithReuseIdentifier: CuisineCategoryCell.reuseIdentifier)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .clear
        cv.decelerationRate = .fast // For snapping to one card at a time
        return cv
    }()

    private lazy var topDishesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.text = "Top Dishes".localized()
        return label
    }()

    private lazy var topDishesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical // Tiles format, so vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.register(TopDishCell.self, forCellWithReuseIdentifier: TopDishCell.reuseIdentifier)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false // Contained within a scroll view, so disable its own scroll
        return cv
    }()

    private lazy var cartButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "cart.fill"), for: .normal)
        button.setTitle("  Go to Cart".localized(), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemGreen
        button.tintColor = .white
        button.layer.cornerRadius = Constants.UI.cornerRadius
        button.addTarget(self, action: #selector(goToCart), for: .touchUpInside)
        button.addShadow()
        return button
    }()
    
    private lazy var languageButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(viewModel.currentLanguage.displayName, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemOrange
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        button.addTarget(self, action: #selector(showLanguageSelection), for: .touchUpInside)
        button.addShadow()
        return button
    }()

    private let activityIndicator = CustomActivityIndicator()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleLanguageChange), name: .languageDidChange, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure content size is correct for the scroll view
        contentView.widthAnchor.constraint(equalToConstant: scrollView.bounds.width).isActive = true
        // Invalidate layout for collection views to re-calculate cell sizes based on current width
        cuisineCategoryCollectionView.collectionViewLayout.invalidateLayout()
        topDishesCollectionView.collectionViewLayout.invalidateLayout()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Restaurant App".localized()
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Add language button to navigation bar
        let languageBarButton = UIBarButtonItem(customView: languageButton)
        navigationItem.rightBarButtonItem = languageBarButton

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(cuisineCategoryLabel)
        contentView.addSubview(cuisineCategoryCollectionView)
        contentView.addSubview(topDishesLabel)
        contentView.addSubview(topDishesCollectionView)
        contentView.addSubview(cartButton)

        // Constraints for scrollView
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                           leading: view.leadingAnchor,
                           bottom: view.bottomAnchor,
                           trailing: view.trailingAnchor)

        // Constraints for contentView
        contentView.anchor(top: scrollView.contentLayoutGuide.topAnchor,
                            leading: scrollView.contentLayoutGuide.leadingAnchor,
                            bottom: scrollView.contentLayoutGuide.bottomAnchor,
                            trailing: scrollView.contentLayoutGuide.trailingAnchor)
        
        // Essential for content size to adapt
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

        // Constraints for Cuisine Category Segment
        cuisineCategoryLabel.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor,
                                    padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
        cuisineCategoryCollectionView.anchor(top: cuisineCategoryLabel.bottomAnchor, leading: contentView.leadingAnchor,
                                             trailing: contentView.trailingAnchor,
                                             padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0),
                                             size: CGSize(width: 0, height: 180)) // Fixed height for cuisine cards

        // Constraints for Top Dishes Segment
        topDishesLabel.anchor(top: cuisineCategoryCollectionView.bottomAnchor, leading: contentView.leadingAnchor,
                              padding: UIEdgeInsets(top: 30, left: 20, bottom: 0, right: 20))
        topDishesCollectionView.anchor(top: topDishesLabel.bottomAnchor, leading: contentView.leadingAnchor,
                                       trailing: contentView.trailingAnchor,
                                       padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        
        // Dynamically adjust height of topDishesCollectionView based on content
        topDishesCollectionView.heightAnchor.constraint(equalToConstant: calculateTopDishesCollectionHeight()).isActive = true
        
        // Constraints for Cart Button
        cartButton.anchor(top: topDishesCollectionView.bottomAnchor,
                           padding: UIEdgeInsets(top: 40, left: 0, bottom: 40, right: 0), // Bottom padding for scroll view content
                           size: CGSize(width: view.bounds.width - 80, height: 50)) // Make it a bit wider

        // Make sure the bottom of the cart button dictates the scroll view's content size
        scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: cartButton.bottomAnchor, constant: 20).isActive = true
    }
    
    private func calculateTopDishesCollectionHeight() -> CGFloat {
        // Calculate height based on number of items and cell size
        let itemsPerRow: CGFloat = 2 // Assuming 2 items per row for tiles
        let cellSpacing: CGFloat = (topDishesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 16
        let sectionInset = (topDishesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? .zero
        
        let availableWidth = view.bounds.width - sectionInset.left - sectionInset.right - (cellSpacing * (itemsPerRow - 1))
        let cellWidth = availableWidth / itemsPerRow
        let cellHeight = cellWidth * 1.2 // Assuming height is 1.2 times the width for a good tile look

        let rowCount = (viewModel.topDishes.count + Int(itemsPerRow) - 1) / Int(itemsPerRow) // Ceiling division
        let totalHeight = CGFloat(rowCount) * cellHeight + CGFloat(rowCount - 1) * cellSpacing + sectionInset.top + sectionInset.bottom
        
        return max(totalHeight, 0) // Ensure non-negative height
    }

    // MARK: - ViewModel Binding

    private func bindViewModel() {
        viewModel.$cuisineCategories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.cuisineCategoryCollectionView.reloadData()
                self?.scrollToCenterCuisine() // Initial scroll to center
            }
            .store(in: &cancellables)

        viewModel.$topDishes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.topDishesCollectionView.reloadData()
                // Update collection view height constraint
                self?.topDishesCollectionView.constraints.first { $0.firstAttribute == .height }?.constant = self?.calculateTopDishesCollectionHeight() ?? 0
                self?.view.layoutIfNeeded() // Relayout to apply new height
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.activityIndicator.show(on: self!.view) : self?.activityIndicator.hide()
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 } // Only pass non-nil values
            .sink { [weak self] message in
                self?.showAlert(title: "Error", message: message)
                Logger.shared.log("Error displayed on Home screen: \(message)", level: .error)
            }
            .store(in: &cancellables)
        
        viewModel.$currentLanguage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] language in
                self?.languageButton.setTitle(language.displayName, for: .normal)
                self?.updateLocalizedStrings()
            }
            .store(in: &cancellables)
    }
    
    private func updateLocalizedStrings() {
        title = "Restaurant App".localized()
        cuisineCategoryLabel.text = "Cuisine Categories".localized()
        topDishesLabel.text = "Top Dishes".localized()
        cartButton.setTitle("  Go to Cart".localized(), for: .normal)
        // Reload data for collection views if cell content relies on localization
        cuisineCategoryCollectionView.reloadData()
        topDishesCollectionView.reloadData()
    }

    // MARK: - Actions

    @objc private func goToCart() {
        Logger.shared.logUserJourney("Navigated to Cart Screen")
        let cartVC = CartViewController()
        navigationController?.pushViewController(cartVC, animated: true)
    }
    
    @objc private func showLanguageSelection() {
        let alert = UIAlertController(title: "Select Language".localized(), message: nil, preferredStyle: .actionSheet)
        
        for lang in [AppLanguage.english, AppLanguage.hindi] {
            alert.addAction(UIAlertAction(title: lang.displayName, style: .default, handler: { [weak self] _ in
                self?.viewModel.switchLanguage(to: lang)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func handleLanguageChange() {
        updateLocalizedStrings()
    }

    // MARK: - Infinite Scroll Helper

    private func scrollToCenterCuisine() {
        guard !viewModel.cuisineCategories.isEmpty else { return }

        // Scroll to the middle item initially
        let initialIndex = max(0, viewModel.cuisineCategories.count / 2)
        let indexPath = IndexPath(item: initialIndex, section: 0)
        
        // This makes sure the selected item is centered
        cuisineCategoryCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
}

// MARK: - UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == cuisineCategoryCollectionView {
            // For infinite scroll, duplicate items for seamless looping
            return viewModel.cuisineCategories.isEmpty ? 0 : viewModel.cuisineCategories.count * 1000 // Large number for "infinite"
        } else if collectionView == topDishesCollectionView {
            return viewModel.topDishes.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == cuisineCategoryCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CuisineCategoryCell.reuseIdentifier, for: indexPath) as? CuisineCategoryCell else {
                return UICollectionViewCell()
            }
            let actualIndex = indexPath.item % viewModel.cuisineCategories.count
            let cuisine = viewModel.cuisineCategories[actualIndex]
            cell.configure(with: cuisine)
            return cell
        } else if collectionView == topDishesCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopDishCell.reuseIdentifier, for: indexPath) as? TopDishCell else {
                return UICollectionViewCell()
            }
            let dish = viewModel.topDishes[indexPath.item]
            cell.configure(with: dish)
            cell.onAddToCart = { [weak self] in
                self?.viewModel.addDishToCart(dish: dish)
                self?.showAlert(title: "Added to Cart".localized(), message: "\(dish.name) added to cart.")
            }
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == cuisineCategoryCollectionView {
            // View one card at a time with some peek for next/prev
            let width = collectionView.bounds.width * 0.85 // Show ~85% of one card
            let height = collectionView.bounds.height
            return CGSize(width: width, height: height)
        } else if collectionView == topDishesCollectionView {
            let itemsPerRow: CGFloat = 2
            let sectionInset = (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? .zero
            let minimumInteritemSpacing = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0
            
            let paddingSpace = sectionInset.left + sectionInset.right + (itemsPerRow - 1) * minimumInteritemSpacing
            let availableWidth = collectionView.bounds.width - paddingSpace
            let widthPerItem = availableWidth / itemsPerRow
            
            return CGSize(width: widthPerItem, height: widthPerItem * 1.2) // Height slightly more than width for tile look
        }
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == cuisineCategoryCollectionView {
            let actualIndex = indexPath.item % viewModel.cuisineCategories.count
            let selectedCuisine = viewModel.cuisineCategories[actualIndex]
            Logger.shared.logUserJourney("Cuisine Category Selected", details: ["cuisineName": selectedCuisine.cuisineName])
            let cuisineDishesVC = CuisineDishesViewController(cuisine: selectedCuisine)
            navigationController?.pushViewController(cuisineDishesVC, animated: true)
        }
    }
    
    // MARK: - Infinite Scroll Handling for Cuisine Category
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == cuisineCategoryCollectionView {
            let contentWidth = scrollView.contentSize.width
            let scrollOffset = scrollView.contentOffset.x
            let boundsWidth = scrollView.bounds.width

            // Logic to simulate infinite scroll
            let buffer: CGFloat = 1.0 / 3.0 // 1/3 of the total scrollable content
            
            if scrollOffset < contentWidth * buffer { // Nearing the beginning
                let offset = contentWidth / 3.0 // Jump to middle of the "copied" content
                scrollView.contentOffset = CGPoint(x: scrollOffset + offset, y: 0)
                Logger.shared.log("Infinite scroll: jumped back to middle (start).", level: .debug)
            } else if scrollOffset > contentWidth * (1.0 - buffer) { // Nearing the end
                let offset = contentWidth / 3.0
                scrollView.contentOffset = CGPoint(x: scrollOffset - offset, y: 0)
                Logger.shared.log("Infinite scroll: jumped back to middle (end).", level: .debug)
            }
            
            // Check if more data needs to be fetched when scrolling near the end
            let scrollThreshold: CGFloat = 0.8 // Fetch when scrolled 80% of the way
            let currentOffset = scrollView.contentOffset.x
            let maximumOffset = scrollView.contentSize.width - scrollView.frame.size.width
            
            if maximumOffset > 0 && currentOffset > maximumOffset * scrollThreshold {
                viewModel.fetchMoreCuisines()
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == cuisineCategoryCollectionView {
            // Snap to grid for one card at a time view
            guard let layout = cuisineCategoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
            
            let cellWidth = layout.itemSize.width + layout.minimumLineSpacing
            
            var offset = targetContentOffset.pointee
            let index = (offset.x + scrollView.contentInset.left) / cellWidth
            var roundedIndex = round(index)
            
            if velocity.x > 0 {
                roundedIndex = floor(index)
            } else if velocity.x < 0 {
                roundedIndex = ceil(index)
            } else {
                roundedIndex = round(index)
            }
            
            // Adjust index for infinite scroll
            let totalCuisines = viewModel.cuisineCategories.count
            if totalCuisines > 0 {
                let currentItem = Int(roundedIndex)
                let actualIndex = currentItem % totalCuisines
                
                // Recalculate target offset based on the actual centered item
                let newTargetOffset = CGPoint(x: CGFloat(actualIndex) * cellWidth - layout.sectionInset.left + (scrollView.bounds.width - cellWidth) / 2, y: 0)
                targetContentOffset.pointee = newTargetOffset
            }
        }
    }
}


// MARK: - UIView Extension for Shadow (Moved here for better organization)
extension UIView {
    func addShadow(color: UIColor = .black, opacity: Float = Constants.UI.shadowOpacity, radius: CGFloat = Constants.UI.shadowRadius, offset: CGSize = Constants.UI.shadowOffset) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
}
