//
//  BuildEntryViewModel.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//


import Foundation
import SwiftUI
import Combine
import CoreData

class BuildEntryViewModel: ObservableObject {
    @Published var uniqueID = ""
    @Published var bmvSerialNumber = ""
    @Published var bmvPIN = ""
    @Published var bmvPUK = ""
    @Published var orionSerialNumber = ""
    @Published var orionPIN = ""
    @Published var orionChargeRate = "18A"
    @Published var mpptSerialNumber = ""
    @Published var mpptPIN = ""
    @Published var shoreChargerSerialNumber = ""
    @Published var builderInitials = ""
    @Published var buildDate = Date()
    @Published var testerInitials = ""
    @Published var testDate = Date()
    
    var bmvPINIsValid: Bool { bmvPIN.count == 6 }
    var orionPINIsValid: Bool { orionPIN.count == 6 }
    var mpptPINIsValid: Bool { mpptPIN.count == 6 }
    


    @Published var showingScanner = false
    @Published var scanningField: ScanField = .bmv
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var showingClearConfirmation = false
    
    private let dataService: DataServiceProtocol
    private let sheetsService: GoogleSheetsServiceProtocol
    
    init(dataService: DataServiceProtocol = DataService(),
         sheetsService: GoogleSheetsServiceProtocol = GoogleSheetsService()) {
        self.dataService = dataService
        self.sheetsService = sheetsService
    }
    
    var isFormValid: Bool {
        !uniqueID.isEmpty &&
        !bmvSerialNumber.isEmpty &&
        !shoreChargerSerialNumber.isEmpty &&
        !builderInitials.isEmpty &&
        bmvPINIsValid && orionPINIsValid && mpptPINIsValid
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
        let record = buildRecord()
        
        Task { @MainActor in
            do {
                // Upload to sheets asynchronously if URL provided
                if !sheetsURL.trimmingCharacters(in: .whitespaces).isEmpty {
                    // Save with "pending" status initially
                    try await dataService.saveBuild(record, syncStatus: "pending")
                    
                    do {
                        try await sheetsService.uploadBuild(record, to: sheetsURL)
                        
                        // Update to "synced" status
                        if let entity = fetchBuildEntity(by: record.id) {
                            try await dataService.updateSyncStatus(entity, status: "synced", error: nil)
                        }
                        alertMessage = "Build saved successfully!\nID: \(uniqueID)\n✅ Uploaded to Google Sheets"
                        showingAlert = true
                    } catch {
                        // Update to "failed" status with error
                        if let entity = fetchBuildEntity(by: record.id) {
                            try? await dataService.updateSyncStatus(entity, status: "failed", error: error.localizedDescription)
                        }
                        alertMessage = "Build saved locally!\nID: \(uniqueID)\n⚠️ Upload failed: \(error.localizedDescription)\n\nYou can retry from the Archive."
                        showingAlert = true
                    }
                } else {
                    // No sheets URL, save as "synced" (no upload needed)
                    try await dataService.saveBuild(record, syncStatus: "synced")
                    alertMessage = "Build saved successfully!\nID: \(uniqueID)"
                    showingAlert = true
                }
                
                clearForm()
            } catch {
                // Handle save error
                print("❌ Failed to save build: \(error.localizedDescription)")
                alertMessage = "Failed to save build: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
    
    // Helper to fetch BuildEntity by UUID
    private func fetchBuildEntity(by id: UUID) -> BuildEntity? {
        let context = PersistenceController.shared.container.viewContext
        let request = BuildEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
    
    private func buildRecord() -> BuildRecord {
        BuildRecord(
            uniqueID: uniqueID,
            bmvSerialNumber: bmvSerialNumber,
            bmvPIN: bmvPIN,
            bmvPUK: bmvPUK,
            orionSerialNumber: orionSerialNumber,
            orionPIN: orionPIN,
            orionChargeRate: orionChargeRate,
            mpptSerialNumber: mpptSerialNumber,
            mpptPIN: mpptPIN,
            shoreChargerSerialNumber: shoreChargerSerialNumber,
            builderInitials: builderInitials,
            buildDate: buildDate,
            testerInitials: testerInitials,
            testDate: testDate
        )
    }
    
    func clearForm() {
        uniqueID = ""
        bmvSerialNumber = ""
        bmvPIN = ""
        bmvPUK = ""
        orionSerialNumber = ""
        orionPIN = ""
        orionChargeRate = "18A"
        mpptSerialNumber = ""
        mpptPIN = ""
        shoreChargerSerialNumber = ""
        builderInitials = ""
        buildDate = Date()
        testerInitials = ""
        testDate = Date()
    }
    
    func showClearConfirmation() {
        showingClearConfirmation = true
    }
    
    func getBindingForScanField() -> Binding<String> {
        switch scanningField {
        case .bmv:
            return Binding(
                get: { self.bmvSerialNumber },
                set: { self.bmvSerialNumber = $0 }
            )
        case .orion:
            return Binding(
                get: { self.orionSerialNumber },
                set: { self.orionSerialNumber = $0 }
            )
        case .mppt:
            return Binding(
                get: { self.mpptSerialNumber },
                set: { self.mpptSerialNumber = $0 }
            )
        case .shoreCharger:
            return Binding(
                get: { self.shoreChargerSerialNumber },
                set: { self.shoreChargerSerialNumber = $0 }
            )
        }
    }
}

