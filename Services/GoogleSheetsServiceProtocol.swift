//
//  GoogleSheetsServiceProtocol.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//


import Foundation

protocol GoogleSheetsServiceProtocol {
    func uploadBuild(_ record: BuildRecord, to url: String)
}

class GoogleSheetsService: GoogleSheetsServiceProtocol {
    func uploadBuild(_ record: BuildRecord, to urlString: String) {
        print("🔵 Attempting to upload to: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            return
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
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: data)
        
        URLSession.shared.dataTask(with: request) { responseData, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🔵 Response status code: \(httpResponse.statusCode)")
            }
            
            if let responseData = responseData,
               let responseString = String(data: responseData, encoding: .utf8) {
                print("🔵 Response: \(responseString)")
            }
        }.resume()
    }
}
