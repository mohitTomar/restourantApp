//
//  Logger.swift
//  RestaurantApp
//
//  Created by Mohit Tomar on 02/06/25.
//

import Foundation

enum LogLevel: String {
    case info = "INFO"
    case debug = "DEBUG"
    case warning = "WARNING"
    case error = "ERROR"
    case severe = "SEVERE" // For critical errors

    var emoji: String {
        switch self {
        case .info: return "ℹ️"
        case .debug: return "🐞"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .severe: return "🚨"
        }
    }
}

class Logger {
    static let shared = Logger()
    private init() {} // Singleton

    private let logQueue = DispatchQueue(label: "com.restaurantapp.loggingQueue", qos: .background)
    private var logBuffer: [String] = []
    private let maxBufferSize = 100 // Maximum logs to keep in memory before considering upload

    // MARK: - Public Logging Methods

    func log(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let timestamp = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)

        let logEntry = "\(timestamp) \(level.emoji) [\(level.rawValue)] [\(fileName):\(line) \(function)] - \(message)"

        print(logEntry) // Print to console for development

        logQueue.async {
            self.logBuffer.append(logEntry)
            if self.logBuffer.count > self.maxBufferSize {
                self.uploadLogsIfNeeded()
            }
        }
    }

    // MARK: - Log Upload Mechanism (Placeholder)

    // In a real app, this would involve sending logs to a remote server
    // e.g., using a dedicated API, Firebase Crashlytics, Sentry, etc.
    private func uploadLogsIfNeeded() {
        // This is a simplified example. In a real application, you'd likely:
        // 1. Check network connectivity.
        // 2. Implement retry logic for failed uploads.
        // 3. Persist logs to disk if upload fails.
        // 4. Send logs in batches.
        // 5. Clear buffer after successful upload.

        guard !logBuffer.isEmpty else { return }

        // Example: Convert logs to a single string or JSON array for upload
        let logsToUpload = logBuffer.joined(separator: "\n")

        // --- Simulate an API call to upload logs ---
        print("\n--- Attempting to upload logs to server ---")
        print(logsToUpload)
        print("--- End of simulated log upload ---\n")

        // In a real scenario:
        // APIManager.shared.uploadLogs(logs: logsToUpload) { result in
        //     switch result {
        //     case .success:
        //         print("Logs uploaded successfully. Clearing buffer.")
        //         self.logQueue.async { self.logBuffer.removeAll() }
        //     case .failure(let error):
        //         print("Failed to upload logs: \(error.localizedDescription). Will retry later.")
        //         // Persist logs to disk for later retry
        //     }
        // }

        // For this example, we'll just clear the buffer after a "simulated" upload
        self.logQueue.async { self.logBuffer.removeAll() }
    }

    // MARK: - User Journey Logging (Example)

    func logUserJourney(_ event: String, details: [String: Any]? = nil) {
        var message = "User Journey: \(event)"
        if let details = details {
            message += " - Details: \(details.map { "\($0.key): \($0.value)" }.joined(separator: ", "))"
        }
        log(message, level: .info)
    }
}
