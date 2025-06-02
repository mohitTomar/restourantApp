//
//  CartViewModel.swift
//  RestaurantApp
//
//  Created by Mohit Tomar on 02/06/25.
//

import Foundation
import Combine

class CartViewModel {
    @Published var cartItems: [CartItem] = []
    @Published var netTotal: Double = 0.0
    @Published var cgstAmount: Double = 0.0
    @Published var sgstAmount: Double = 0.0
    @Published var grandTotal: Double = 0.0
    @Published var isLoading: Bool = false
    @Published var paymentSuccessMessage: String?
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Subscribe to changes in CartManager
        CartManager.shared.$cartItems
            .sink { [weak self] updatedItems in
                self?.cartItems = updatedItems
                self?.updateTotals()
            }
            .store(in: &cancellables)

        updateTotals() // Initial update
    }

    private func updateTotals() {
        netTotal = CartManager.shared.netTotal
        cgstAmount = CartManager.shared.cgstAmount
        sgstAmount = CartManager.shared.sgstAmount
        grandTotal = CartManager.shared.grandTotal
        Logger.shared.log("Cart totals updated: Net Total=\(netTotal)", level: .debug)
    }

    func addDishToCart(dish: Dish) {
        CartManager.shared.addDishToCart(dish: dish)
        Logger.shared.logUserJourney("Cart - Dish Quantity Increased", details: ["dishId": dish.id])
    }

    func removeDishFromCart(dish: Dish) {
        CartManager.shared.removeDishFromCart(dish: dish)
        Logger.shared.logUserJourney("Cart - Dish Quantity Decreased/Removed", details: ["dishId": dish.id])
    }

    func placeOrder() {
        guard !cartItems.isEmpty else {
            errorMessage = "Your cart is empty. Please add items before placing an order."
            Logger.shared.log("Attempted to place order with empty cart.", level: .warning)
            return
        }
        
        Logger.shared.logUserJourney("Place Order Button Tapped", details: ["grandTotal": grandTotal, "itemCount": cartItems.count])

        isLoading = true
        errorMessage = nil
        paymentSuccessMessage = nil

        let paymentItems = cartItems.map { item in
            PaymentItem(
                cuisineId: "N/A", // The API doesn't provide cuisine_id in the dish details for `get_item_by_filter`
                                  // or `get_item_list` (directly on the item). It's associated with cuisine.
                                  // For a real app, you'd need to store the cuisine_id with the dish.
                                  // For now, using a placeholder or try to infer.
                                  // If `get_item_by_id` was used to fetch a dish, it returns `cuisine_id`.
                                  // This highlights a potential data model gap if `cuisine_id` is crucial for payment.
                                  // I'll make an assumption for `cuisine_id` or use a dummy if not explicitly available.
                                  // Let's assume for `Dish` model, we could add `cuisineId: String?`.
                                  // Since it's not directly in `Dish` model, I'll use a dummy/fixme.
                itemId: item.dish.id,
                itemPrice: Double(item.dish.price) ?? 0.0,
                itemQuantity: item.quantity
            )
        }

        let requestBody = MakePaymentRequestBody(
            totalAmount: String(format: "%.2f", grandTotal),
            totalItems: cartItems.reduce(0) { $0 + $1.quantity },
            data: paymentItems
        )

        APIManager.shared.makePayment(requestBody: requestBody)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                    Logger.shared.log("Payment failed: \(error.localizedDescription)", level: .error)
                    Logger.shared.logUserJourney("Payment Failed", details: ["error": error.localizedDescription])
                }
            } receiveValue: { [weak self] response in
                if response.responseCode == 200 && response.outcomeCode == 200 {
                    self?.paymentSuccessMessage = response.responseMessage + "\nTransaction Ref: \(response.txnRefNo)"
                    CartManager.shared.clearCart() // Clear cart on successful order
                    Logger.shared.log("Order placed successfully. Txn Ref: \(response.txnRefNo)", level: .info)
                    Logger.shared.logUserJourney("Payment Successful", details: ["txnRefNo": response.txnRefNo])
                } else {
                    self?.errorMessage = response.responseMessage
                    Logger.shared.log("Payment API returned non-success code: \(response.responseMessage)", level: .error)
                    Logger.shared.logUserJourney("Payment API Error", details: ["responseMessage": response.responseMessage])
                }
            }
            .store(in: &cancellables)
    }
}
