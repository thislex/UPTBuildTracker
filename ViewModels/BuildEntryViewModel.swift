//
//  BuildEntryViewModel.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//


import Foundation
import SwiftUI
import Combine

class BuildEntryViewModel: ObservableObject {
    @Published var uniqueID = ""
    @Published var bmvSerialNumber = ""
    @Published var bmvPIN = ""
    @Published var orionSerialNumber = ""
    @Published var orionPIN = ""
    @Published var mpptSerialNumber = ""
    @Published var mpptPIN = ""
    @Published var builderInitials = ""
    @Published var buildDate = Date()
    @Published var testerInitials = ""
    @Published var testDate = Date()
    
    @Published var showingScanner = false
    @Published var scanningField: ScanField = .bmv
    @Published var showingAlert = false
    @Published var alertMessage = ""
    
    private let dataService: DataServiceProtocol
    private let sheetsService: GoogleSheetsServiceProtocol
    
    init(dataService: DataServiceProtocol = DataService(),
         sheetsService: GoogleSheetsServiceProtocol = GoogleSheetsService()) {
        self.dataService = dataService
        self.sheetsService = sheetsService
    }
    
    var isFormValid: Bool {
        !uniqueID.isEmpty && !bmvSerialNumber.isEmpty && !builderInitials.isEmpty && !testerInitials.isEmpty
    }
    
    func generateUniqueID() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateString = formatter.string(from: Date())
        let random = Int.random(in: 1000...9999)
        uniqueID = "BUILD-\(dateString)-\(random)"
    }
    
    func scanSerial(for field: ScanField) {
        scanningField = field
        showingScanner = true
    }
    
    func saveBuild(sheetsURL: String) {
        let record = BuildRecord(
            uniqueID: uniqueID,
            bmvSerialNumber: bmvSerialNumber,
            bmvPIN: bmvPIN,
            orionSerialNumber: orionSerialNumber,
            orionPIN: orionPIN,
            mpptSerialNumber: mpptSerialNumber,
            mpptPIN: mpptPIN,
            builderInitials: builderInitials,
            buildDate: buildDate,
            testerInitials: testerInitials,
            testDate: testDate
        )
        
        dataService.saveBuild(record)
        
        if !sheetsURL.isEmpty {
            sheetsService.uploadBuild(record, to: sheetsURL)
        }
        
        alertMessage = "Build saved successfully!\nID: \(uniqueID)"
        showingAlert = true
        clearForm()
    }
    
    func clearForm() {
        uniqueID = ""
        bmvSerialNumber = ""
        bmvPIN = ""
        orionSerialNumber = ""
        orionPIN = ""
        mpptSerialNumber = ""
        mpptPIN = ""
        builderInitials = ""
        buildDate = Date()
        testerInitials = ""
        testDate = Date()
    }
    
    func getBindingForScanField() -> Binding<String> {
        switch scanningField {
        case .bmv:
            return $bmvSerialNumber
        case .orion:
            return $orionSerialNumber
        case .mppt:
            return $mpptSerialNumber
        }
    }
}