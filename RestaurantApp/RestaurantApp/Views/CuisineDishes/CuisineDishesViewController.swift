//
//  CuisineDishesViewController.swift
//  RestaurantApp
//
//  Created by Mohit Tomar on 02/06/25.
//

import UIKit
import Combine

class CuisineDishesViewController: UIViewController {

    private var viewModel: CuisineDishesViewModel!
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private lazy var dishesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = true
        cv.register(DishListItemCell.self, forCellWithReuseIdentifier: DishListItemCell.reuseIdentifier)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .systemBackground
        return cv
    }()
    
    private let activityIndicator = CustomActivityIndicator()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No dishes found for this cuisine.".localized()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.isHidden = true // Initially hidden
        return label
    }()

    // MARK: - Initialization

    init(cuisine: Cuisine) {
        self.viewModel = CuisineDishesViewModel(cuisine: cuisine)
        super.init(nibName: nil, bundle: nil)
        title = cuisine.cuisineName.localized()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        navigationController?.navigationBar.prefersLargeTitles = false // Optional: smaller title for detail screen

        view.addSubview(dishesCollectionView)
        view.addSubview(emptyStateLabel)

        dishesCollectionView.fillSuperview()
        emptyStateLabel.centerX(in: view)
        emptyStateLabel.centerY(in: view)
    }

    // MARK: - ViewModel Binding

    private func bindViewModel() {
        viewModel.$dishes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.dishesCollectionView.reloadData()
                self?.emptyStateLabel.isHidden = !(self?.viewModel.dishes.isEmpty ?? true)
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
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.showAlert(title: "Error", message: message)
                Logger.shared.log("Error displayed on Cuisine Dishes screen: \(message)", level: .error)
            }
            .store(in: &cancellables)
    }
    
    @objc private func handleLanguageChange() {
        title = viewModel.dishes.first?.name.localized() ?? "Dishes".localized() // Re-localize title
        emptyStateLabel.text = "No dishes found for this cuisine.".localized()
        dishesCollectionView.reloadData() // Reload cells to update localized content
    }
}

// MARK: - UICollectionViewDataSource

extension CuisineDishesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.dishes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DishListItemCell.reuseIdentifier, for: indexPath) as? DishListItemCell else {
            return UICollectionViewCell()
        }
        let dish = viewModel.dishes[indexPath.item]
        cell.configure(with: dish)
        cell.onAddToCart = { [weak self] in
            self?.viewModel.addDishToCart(dish: dish)
            self?.showAlert(title: "Added to Cart".localized(), message: "\(dish.name) added to cart.")
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CuisineDishesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 1 // One item per row for a list feel, adjust if you want 2 columns
        let sectionInset = (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? .zero
        let minimumInteritemSpacing = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0
        
        let paddingSpace = sectionInset.left + sectionInset.right + (itemsPerRow - 1) * minimumInteritemSpacing
        let availableWidth = collectionView.bounds.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: 120) // Fixed height for list item
    }
}
