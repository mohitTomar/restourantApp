//
//  CartItem.swift
//  RestaurantApp
//
//  Created by Mohit Tomar on 02/06/25.
//

import Foundation

struct CartItem: Identifiable, Equatable, Hashable {
    let id = UUID() // Unique identifier for SwiftUI List/ForEach if used, or for internal tracking
    let dish: Dish
    var quantity: Int

    var totalPrice: Double {
        return (Double(dish.price) ?? 0.0) * Double(quantity)
    }
}
