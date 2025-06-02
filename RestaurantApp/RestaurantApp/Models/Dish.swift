//
//  Dish.swift
//  RestaurantApp
//
//  Created by Mohit Tomar on 02/06/25.
//

import Foundation

struct Dish: Codable, Hashable {
    var id: String
    var name: String
    var imageUrl: String?
    var price: String
    let rating: String?

    // For get_item_by_id response, the keys are different
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageUrl = "image_url"
        case price
        case rating

        // Aliases for get_item_by_id response
        case itemId = "item_id"
        case itemName = "item_name"
        case itemImageUrl = "item_image_url"
        case itemPrice = "item_price"
        case itemRating = "item_rating"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Try decoding from one set of keys, then another
        do {
            id = try container.decode(String.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
            price = try container.decode(String.self, forKey: .price)
            rating = try container.decodeIfPresent(String.self, forKey: .rating)
        } catch {
            // If the above fails, try decoding with 'item_' prefixed keys
            id = try container.decode(String.self, forKey: .itemId)
            name = try container.decode(String.self, forKey: .itemName)
            imageUrl = try container.decodeIfPresent(String.self, forKey: .itemImageUrl)
            
            // Handle item_price which can be Int or String
            if let itemPriceInt = try? container.decode(Int.self, forKey: .itemPrice) {
                price = String(itemPriceInt)
            } else {
                price = try container.decode(String.self, forKey: .itemPrice)
            }
            
            // Handle item_rating which can be Double or String
            if let itemRatingDouble = try? container.decode(Double.self, forKey: .itemRating) {
                rating = String(itemRatingDouble)
            } else {
                rating = try container.decodeIfPresent(String.self, forKey: .itemRating)
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(price, forKey: .price)
        try container.encode(rating, forKey: .rating)
    }

    // Custom initializer for creating Dish objects easily
    init(id: String, name: String, imageUrl: String?, price: String, rating: String?) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.price = price
        self.rating = rating
    }
}
