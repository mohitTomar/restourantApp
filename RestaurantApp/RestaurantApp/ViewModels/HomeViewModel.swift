//
//  HomeViewModel.swift
//  RestaurantApp
//
//  Created by Mohit Tomar on 02/06/25.
//

import Foundation
import Combine

class HomeViewModel {
    @Published var cuisineCategories: [Cuisine] = []
    @Published var topDishes: [Dish] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var currentLanguage: AppLanguage = .english // Default

    private var currentPage = 1
    private let itemsPerPage = 10
    private var totalCuisinesAvailable = 0
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Load initial language preference
        if let savedLangCode = UserDefaults.standard.string(forKey: UserDefaults.selectedLanguageKey),
           let savedLanguage = AppLanguage(rawValue: savedLangCode) {
            currentLanguage = savedLanguage
        } else {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: UserDefaults.selectedLanguageKey)
        }
        
        fetchInitialData()
    }

    func fetchInitialData() {
        Logger.shared.logUserJourney("Home Screen Loaded")
        isLoading = true
        errorMessage = nil

        // Fetch cuisine categories
        APIManager.shared.getCuisineList(page: currentPage, count: itemsPerPage)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                    Logger.shared.log("Failed to fetch cuisine list: \(error.localizedDescription)", level: .error)
                }
            } receiveValue: { [weak self] response in
                self?.cuisineCategories = response.cuisines
                self?.totalCuisinesAvailable = response.totalItems // Assuming totalItems refers to total cuisines
                Logger.shared.log("Fetched \(response.cuisines.count) cuisine categories.", level: .info)
            }
            .store(in: &cancellables)

        // Fetch top 3 famous dishes (using a min_rating filter)
        APIManager.shared.getTopFamousDishes(minRating: 4.0) // Assuming 4.0 is a good threshold for "famous"
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    // It's possible no dishes meet the filter, don't show error if response is just empty
                    if error.localizedDescription != "API Error: No dishes found for the given filter." { // Customize based on actual API error messages
                         self?.errorMessage = error.localizedDescription
                         Logger.shared.log("Failed to fetch top dishes: \(error.localizedDescription)", level: .error)
                    }
                }
            } receiveValue: { [weak self] response in
                // Combine all items from all cuisines returned by the filter, then pick top 3
                let allFilteredDishes = response.cuisines.compactMap { $0.items }.flatMap { $0 }
                // Sort by rating (if rating is a number, otherwise just pick first 3 arbitrarily)
                self?.topDishes = allFilteredDishes.sorted { (Double($0.rating ?? "0") ?? 0) > (Double($1.rating ?? "0") ?? 0) }.prefix(3).map { $0 }
                Logger.shared.log("Fetched \(self?.topDishes.count ?? 0) top dishes.", level: .info)
            }
            .store(in: &cancellables)
    }

    func fetchMoreCuisines() {
        guard !isLoading else { return }
        // Basic pagination/infinite scroll: load next page if not all cuisines are loaded
        if cuisineCategories.count < totalCuisinesAvailable {
            currentPage += 1
            isLoading = true
            APIManager.shared.getCuisineList(page: currentPage, count: itemsPerPage)
                .sink { [weak self] completion in
                    self?.isLoading = false
                    if case let .failure(error) = completion {
                        self?.errorMessage = error.localizedDescription
                        Logger.shared.log("Failed to fetch more cuisine list: \(error.localizedDescription)", level: .error)
                    }
                } receiveValue: { [weak self] response in
                    self?.cuisineCategories.append(contentsOf: response.cuisines)
                    Logger.shared.log("Fetched more cuisine categories. Total: \(self?.cuisineCategories.count ?? 0)", level: .info)
                }
                .store(in: &cancellables)
        } else {
            Logger.shared.log("All cuisines loaded.", level: .info)
        }
    }

    func addDishToCart(dish: Dish) {
        CartManager.shared.addDishToCart(dish: dish)
    }
    
    func switchLanguage(to newLanguage: AppLanguage) {
        currentLanguage = newLanguage
        UserDefaults.standard.set(newLanguage.rawValue, forKey: UserDefaults.selectedLanguageKey)
        Logger.shared.logUserJourney("Language Switched", details: ["language": newLanguage.rawValue])
        // Post a notification so UI can update immediately
        NotificationCenter.default.post(name: .languageDidChange, object: nil)
    }
}

extension Notification.Name {
    static let languageDidChange = Notification.Name("languageDidChange")
}
