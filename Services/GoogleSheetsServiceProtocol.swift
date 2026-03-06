//
//  GoogleSheetsServiceProtocol.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//


import Foundation

protocol GoogleSheetsServiceProtocol {
    func uploadBuild(_ record: BuildRecord, to url: String) async throws
}

// Google Apps Script runs doPost on the first POST and returns a 302 redirect.
// We stop here — data is already saved. Following the redirect causes a secondary
// failure since the redirect URL doesn't accept POST.
private class PostRedirectHandler: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(nil) // Don't follow the redirect; treat 302 as success
    }
}

class GoogleSheetsService: GoogleSheetsServiceProtocol {
    private let session = URLSession(configuration: .default, delegate: PostRedirectHandler(), delegateQueue: nil)

    func uploadBuild(_ record: BuildRecord, to urlString: String) async throws {
        print("🔵 Attempting to upload to: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let data: [String: Any] = [
            "uniqueID": record.uniqueID,
            "bmvSerialNumber": record.bmvSerialNumber,
            "bmvPIN": record.bmvPIN,
            "bmvPUK": record.bmvPUK,
            "orionSerialNumber": record.orionSerialNumber,
            "orionPIN": record.orionPIN,
            "orionChargeRate": record.orionChargeRate,
            "mpptSerialNumber": record.mpptSerialNumber,
            "mpptPIN": record.mpptPIN,
            "shoreChargerSerialNumber": record.shoreChargerSerialNumber,
            "builderInitials": record.builderInitials,
            "buildDate": record.formattedBuildDate,
            "testerInitials": record.testerInitials,
            "testDate": record.formattedTestDate
        ]

        print("🔵 Data to send: \(data)")

        request.httpBody = try JSONSerialization.data(withJSONObject: data)

        let (responseData, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("🔵 Response status code: \(httpResponse.statusCode)")

            guard 200...399 ~= httpResponse.statusCode else {
                throw URLError(.badServerResponse)
            }
        }

        if let responseString = String(data: responseData, encoding: .utf8) {
            print("🔵 Response: \(responseString)")
        }
    }
}
