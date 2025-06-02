//
//  CartManager.swift
//  RestaurantApp
//
//  Created by Mohit Tomar on 02/06/25.
//

import Foundation
import Combine

class CartManager {
    static let shared = CartManager()
    private init() {}

    @Published private(set) var cartItems: [CartItem] = [] {
        didSet {
            // Save cart to UserDefaults or a persistent store if needed
            // For simplicity, we'll keep it in memory for this example
            Logger.shared.log("Cart items updated: \(cartItems.count) items", level: .debug)
        }
    }

    var netTotal: Double {
        return cartItems.reduce(0) { $0 + $1.totalPrice }
    }

    var cgstAmount: Double {
        return netTotal * Constants.Cart.cgstPercentage
    }

    var sgstAmount: Double {
        return netTotal * Constants.Cart.sgstPercentage
    }

    var grandTotal: Double {
        return netTotal + cgstAmount + sgstAmount
    }

    func addDishToCart(dish: Dish) {
        if let index = cartItems.firstIndex(where: { $0.dish.id == dish.id }) {
            cartItems[index].quantity += 1
            Logger.shared.log("Increased quantity for dish: \(dish.name). New quantity: \(cartItems[index].quantity)", level: .info)
        } else {
            let newCartItem = CartItem(dish: dish, quantity: 1)
            cartItems.append(newCartItem)
            Logger.shared.log("Added new dish to cart: \(dish.name)", level: .info)
        }
        Logger.shared.logUserJourney("Dish Added to Cart", details: ["dishId": dish.id, "dishName": dish.name])
    }

    func removeDishFromCart(dish: Dish) {
        if let index = cartItems.firstIndex(where: { $0.dish.id == dish.id }) {
            if cartItems[index].quantity > 1 {
                cartItems[index].quantity -= 1
                Logger.shared.log("Decreased quantity for dish: \(dish.name). New quantity: \(cartItems[index].quantity)", level: .info)
            } else {
                cartItems.remove(at: index)
                Logger.shared.log("Removed dish from cart: \(dish.name)", level: .info)
            }
        }
        Logger.shared.logUserJourney("Dish Removed from Cart", details: ["dishId": dish.id, "dishName": dish.name])
    }

    func clearCart() {
        cartItems.removeAll()
        Logger.shared.log("Cart cleared.", level: .info)
        Logger.shared.logUserJourney("Cart Cleared")
    }
}
