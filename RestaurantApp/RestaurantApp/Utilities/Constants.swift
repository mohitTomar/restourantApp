//
//  Constants.swift
//  RestaurantApp
//
//  Created by Mohit Tomar on 02/06/25.
//

import Foundation

struct Constants {
    static let baseURL = "https://uat.onebanc.ai"
    static let partnerAPIKey = "uonebancservceemultrS3cg8RaL30"

    struct APIEndpoints {
        static let getItemList = "/emulator/interview/get_item_list"
        static let getItemById = "/emulator/interview/get_item_by_id"
        static let getItemByFilter = "/emulator/interview/get_item_by_filter"
        static let makePayment = "/emulator/interview/make_payment"
    }

    struct UI {
        static let cornerRadius: CGFloat = 12.0
        static let shadowOpacity: Float = 0.2
        static let shadowRadius: CGFloat = 4.0
        static let shadowOffset: CGSize = CGSize(width: 0, height: 2)
    }

    struct Localization {
        static let englishCode = "en"
        static let hindiCode = "hi"
    }

    struct Cart {
        static let cgstPercentage: Double = 0.025
        static let sgstPercentage: Double = 0.025
    }
}

enum AppLanguage: String {
    case english = "en"
    case hindi = "hi"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .hindi: return "हिंदी"
        }
    }
}

// UserDefault Keys
extension UserDefaults {
    static let selectedLanguageKey = "selectedAppLanguage"
}
