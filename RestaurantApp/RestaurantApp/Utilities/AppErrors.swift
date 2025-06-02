//
//  AppErrors.swift
//  RestaurantApp
//
//  Created by Mohit Tomar on 02/06/25.
//

import Foundation

enum AppError: Error, LocalizedError {
    case networkError(String)
    case decodingError(String)
    case apiError(String)
    case invalidURL
    case unknownError

    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .decodingError(let message):
            return "Data Decoding Error: \(message)"
        case .apiError(let message):
            return "API Error: \(message)"
        case .invalidURL:
            return "Invalid URL"
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}
