//
//  Cuisine.swift
//  RestaurantApp
//
//  Created by Mohit Tomar on 02/06/25.
//

import Foundation

struct Cuisine: Codable, Hashable {
    let cuisineId: String
    let cuisineName: String
    let cuisineImageUrl: String?
    let items: [Dish]? // Optional because get_item_by_filter might not return items directly

    enum CodingKeys: String, CodingKey {
        case cuisineId = "cuisine_id"
        case cuisineName = "cuisine_name"
        case cuisineImageUrl = "cuisine_image_url"
        case items
    }
}
