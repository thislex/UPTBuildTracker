import Foundation

protocol GoogleSheetsServiceProtocol {
    func uploadBuild(_ record: BuildRecord, to url: String)
}

class GoogleSheetsService: GoogleSheetsServiceProtocol {
    func uploadBuild(_ record: BuildRecord, to urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data: [String: Any] = [
            "uniqueID": record.uniqueID,
            "bmvSerialNumber": record.bmvSerialNumber,
            "bmvPIN": record.bmvPIN,
            "orionSerialNumber": record.orionSerialNumber,
            "orionPIN": record.orionPIN,
            "mpptSerialNumber": record.mpptSerialNumber,
            "mpptPIN": record.mpptPIN,
            "builderInitials": record.builderInitials,
            "buildDate": record.formattedBuildDate,
            "testerInitials": record.testerInitials,
            "testDate": record.formattedTestDate
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: data)
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            // Handle response if needed
        }.resume()
    }
}