//
//  APIResponses.swift
//  RestaurantApp
//
//  Created by Mohit Tomar on 02/06/25.
//

import Foundation

// MARK: - Get Item List Response

struct GetItemListResponse: Codable {
    let responseCode: Int
    let outcomeCode: Int
    let responseMessage: String
    let page: Int
    let count: Int
    let totalPages: Int
    let totalItems: Int
    let cuisines: [Cuisine]

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case outcomeCode = "outcome_code"
        case responseMessage = "response_message"
        case page, count, totalPages = "total_pages", totalItems = "total_items", cuisines
    }
}

// MARK: - Get Item By ID Response

struct GetItemByIdResponse: Codable {
    let responseCode: Int
    let outcomeCode: Int
    let responseMessage: String
    let cuisineId: String
    let cuisineName: String
    let cuisineImageUrl: String?
    let itemId: String
    let itemName: String
    let itemPrice: Double
    let itemRating: Double
    let itemImageUrl: String?

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case outcomeCode = "outcome_code"
        case responseMessage = "response_message"
        case cuisineId = "cuisine_id"
        case cuisineName = "cuisine_name"
        case cuisineImageUrl = "cuisine_image_url"
        case itemId = "item_id"
        case itemName = "item_name"
        case itemPrice = "item_price"
        case itemRating = "item_rating"
        case itemImageUrl = "item_image_url"
    }

    // Helper to convert to Dish model
    var toDish: Dish {
        return Dish(
            id: itemId,
            name: itemName,
            imageUrl: itemImageUrl,
            price: String(itemPrice),
            rating: String(itemRating)
        )
    }
}


// MARK: - Get Item By Filter Response

struct GetItemByFilterResponse: Codable {
    let responseCode: Int
    let outcomeCode: Int
    let responseMessage: String
    let cuisines: [Cuisine]

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case outcomeCode = "outcome_code"
        case responseMessage = "response_message"
        case cuisines
    }
}

// MARK: - Make Payment Request Body

struct MakePaymentRequestBody: Codable {
    let totalAmount: String
    let totalItems: Int
    let data: [PaymentItem]

    enum CodingKeys: String, CodingKey {
        case totalAmount = "total_amount"
        case totalItems = "total_items"
        case data
    }
}

struct PaymentItem: Codable {
    let cuisineId: String
    let itemId: String
    let itemPrice: Double
    let itemQuantity: Int

    enum CodingKeys: String, CodingKey {
        case cuisineId = "cuisine_id"
        case itemId = "item_id"
        case itemPrice = "item_price"
        case itemQuantity = "item_quantity"
    }
}

// MARK: - Make Payment Response

struct MakePaymentResponse: Codable {
    let responseCode: Int
    let outcomeCode: Int
    let responseMessage: String
    let txnRefNo: String

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case outcomeCode = "outcome_code"
        case responseMessage = "response_message"
        case txnRefNo = "txn_ref_no"
    }
}
