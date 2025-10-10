//
//  BuildRecord.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//


import Foundation

struct BuildRecord: Identifiable, Codable {
    var id: UUID = UUID()
    var uniqueID: String
    var bmvSerialNumber: String
    var bmvPIN: String
    var orionSerialNumber: String
    var orionPIN: String
    var mpptSerialNumber: String
    var mpptPIN: String
    var builderInitials: String
    var buildDate: Date
    var testerInitials: String
    var testDate: Date
    var createdAt: Date = Date()
    
    var formattedBuildDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: buildDate)
    }
    
    var formattedTestDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: testDate)
    }
}