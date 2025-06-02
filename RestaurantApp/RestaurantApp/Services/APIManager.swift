//
//  APIManager.swift
//  RestaurantApp
//
//  Created by Mohit Tomar on 02/06/25.
//

import Foundation
import Combine // For reactive programming

class APIManager {
    static let shared = APIManager()
    private init() {
        // Configure URLCache for image caching
        let cacheSizeMemory = 100 * 1024 * 1024 // 100 MB
        let cacheSizeDisk = 200 * 1024 * 1024 // 200 MB
        let urlCache = URLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: "ImageCache")
        URLCache.shared = urlCache
    }

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30 // seconds
        config.timeoutIntervalForResource = 60 // seconds
        return URLSession(configuration: config)
    }()

    // Generic request function
    func request<T: Codable>(
        endpoint: String,
        method: String,
        headers: [String: String],
        body: [String: Any]? = nil,
        responseType: T.Type
    ) -> AnyPublisher<T, AppError> {

        guard var urlComponents = URLComponents(string: Constants.baseURL + endpoint) else {
            return Fail(error: AppError.invalidURL).eraseToAnyPublisher()
        }

        // Add query parameters if needed (though current APIs use body)
        if method == "GET", let body = body {
            urlComponents.queryItems = body.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }

        guard let url = urlComponents.url else {
            return Fail(error: AppError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers

        // Security headers example (though not strictly required by the API, good practice)
        // request.setValue("Bearer YOUR_AUTH_TOKEN", forHTTPHeaderField: "Authorization") // For OAuth/JWT
        // request.setValue("application/json", forHTTPHeaderField: "Accept") // Indicate acceptance of JSON

        if let body = body, method != "GET" {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                Logger.shared.log("Failed to serialize request body: \(error.localizedDescription)", level: .error)
                return Fail(error: AppError.decodingError("Failed to serialize request body.")).eraseToAnyPublisher()
            }
        }
        
        Logger.shared.log("Making API call: \(endpoint) with body: \(body ?? [:])", level: .debug)

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    Logger.shared.log("Invalid HTTP response.", level: .error)
                    throw AppError.networkError("Invalid HTTP response.")
                }
                
                Logger.shared.log("API Response Status for \(endpoint): \(httpResponse.statusCode)", level: .debug)
                Logger.shared.log("API Response Data for \(endpoint): \(String(data: data, encoding: .utf8) ?? "N/A")", level: .debug)

                // Implement advanced error handling based on status codes
                if httpResponse.statusCode == 401 {
                    Logger.shared.log("Unauthorized request for \(endpoint).", level: .error)
                    throw AppError.apiError("Unauthorized. Please log in again.")
                } else if httpResponse.statusCode == 400 {
                    // Try to decode a more specific error message from the response body
                    if let errorResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let errorMessage = errorResponse["response_message"] as? String {
                        Logger.shared.log("Bad Request for \(endpoint): \(errorMessage)", level: .error)
                        throw AppError.apiError("Bad Request: \(errorMessage)")
                    } else {
                        Logger.shared.log("Bad Request for \(endpoint).", level: .error)
                        throw AppError.apiError("Bad Request.")
                    }
                } else if !(200..<300).contains(httpResponse.statusCode) {
                    Logger.shared.log("HTTP Error \(httpResponse.statusCode) for \(endpoint).", level: .error)
                    throw AppError.networkError("HTTP Error: \(httpResponse.statusCode)")
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if let decodingError = error as? DecodingError {
                    Logger.shared.log("Decoding error for \(endpoint): \(decodingError.localizedDescription)", level: .error)
                    return AppError.decodingError(decodingError.localizedDescription)
                } else if let appError = error as? AppError {
                    return appError
                } else {
                    Logger.shared.log("Unknown error in API call for \(endpoint): \(error.localizedDescription)", level: .error)
                    return AppError.unknownError
                }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Specific API Calls

    func getCuisineList(page: Int, count: Int) -> AnyPublisher<GetItemListResponse, AppError> {
        let headers = [
            "X-Partner-API-Key": Constants.partnerAPIKey,
            "X-Forward-Proxy-Action": "get_item_list",
            "Content-Type": "application/json"
        ]
        let body: [String: Any] = [
            "page": page,
            "count": count
        ]
        return request(endpoint: Constants.APIEndpoints.getItemList, method: "POST", headers: headers, body: body, responseType: GetItemListResponse.self)
    }

    func getItemById(itemId: String) -> AnyPublisher<GetItemByIdResponse, AppError> {
        let headers = [
            "X-Partner-API-Key": Constants.partnerAPIKey,
            "X-Forward-Proxy-Action": "get_item_by_id",
            "Content-Type": "application/json"
        ]
        let body: [String: Any] = [
            "item_id": itemId
        ]
        return request(endpoint: Constants.APIEndpoints.getItemById, method: "POST", headers: headers, body: body, responseType: GetItemByIdResponse.self)
    }

    func getTopFamousDishes(minRating: Double) -> AnyPublisher<GetItemByFilterResponse, AppError> {
        let headers = [
            "X-Partner-API-Key": Constants.partnerAPIKey,
            "X-Forward-Proxy-Action": "get_item_by_filter",
            "Content-Type": "application/json"
        ]
        let body: [String: Any] = [
            "min_rating": minRating
        ]
        return request(endpoint: Constants.APIEndpoints.getItemByFilter, method: "POST", headers: headers, body: body, responseType: GetItemByFilterResponse.self)
    }

    func makePayment(requestBody: MakePaymentRequestBody) -> AnyPublisher<MakePaymentResponse, AppError> {
        let headers = [
            "X-Partner-API-Key": Constants.partnerAPIKey,
            "X-Forward-Proxy-Action": "make_payment",
            "Content-Type": "application/json"
        ]
        
        do {
            let encodedBody = try JSONEncoder().encode(requestBody)
            if let json = try JSONSerialization.jsonObject(with: encodedBody, options: []) as? [String: Any] {
                return request(endpoint: Constants.APIEndpoints.makePayment, method: "POST", headers: headers, body: json, responseType: MakePaymentResponse.self)
            } else {
                Logger.shared.log("Failed to convert MakePaymentRequestBody to [String: Any]", level: .error)
                return Fail(error: AppError.decodingError("Failed to convert payment body.")).eraseToAnyPublisher()
            }
        } catch {
            Logger.shared.log("Error encoding MakePaymentRequestBody: \(error.localizedDescription)", level: .error)
            return Fail(error: AppError.decodingError("Failed to encode payment request body.")).eraseToAnyPublisher()
        }
    }
    
    // MARK: - Advanced Security Notes
    /*
     For AES encryption: This would typically be applied to sensitive data within the request body *before* sending, and data would be decrypted on the server. The key management is crucial here. iOS offers `CommonCrypto` or `CryptoKit` (iOS 13+) for AES operations.

     For OAuth/JWT authentication:
     1. **OAuth:** Involves a multi-step flow where the app redirects to an authorization server, gets an authorization code, exchanges it for an access token (and refresh token) on the backend or securely within the app. The access token is then sent in the `Authorization: Bearer <token>` header for subsequent API calls.
     2. **JWT:** The server issues a JWT. This token is then stored securely (e.g., Keychain) and attached to `Authorization` headers. The server verifies the token's signature and expiration.

     Both would involve secure storage of tokens (Keychain is recommended) and refresh token mechanisms to get new access tokens when they expire. The `APIManager` would be the place to inject these tokens into the request headers.
     */
}
