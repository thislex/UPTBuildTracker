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

    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var showingClearConfirmation = false
    @Published var isSaving = false
    @Published var saveProgress: Double = 0
    @Published var saveStatusMessage = ""
    
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
    
    func saveBuild(sheetsURL: String) {
        let record = buildRecord()

        Task { @MainActor in
            isSaving = true
            saveProgress = 0.1
            saveStatusMessage = "Saving build..."

            do {
                if !sheetsURL.trimmingCharacters(in: .whitespaces).isEmpty {
                    try await dataService.saveBuild(record, syncStatus: "pending")
                    saveProgress = 0.4
                    saveStatusMessage = "Saved locally. Uploading to Google Sheets..."

                    do {
                        try await sheetsService.uploadBuild(record, to: sheetsURL)
                        saveProgress = 0.85
                        saveStatusMessage = "Finalizing..."

                        if let entity = fetchBuildEntity(by: record.id) {
                            try await dataService.updateSyncStatus(entity, status: "synced", error: nil)
                        }
                        saveProgress = 1.0
                        saveStatusMessage = "Done!"
                        alertMessage = "Build saved successfully!\nUPT ID: \(uniqueID)\n✅ Uploaded to Google Sheets"
                    } catch {
                        if let entity = fetchBuildEntity(by: record.id) {
                            try? await dataService.updateSyncStatus(entity, status: "failed", error: error.localizedDescription)
                        }
                        saveProgress = 1.0
                        saveStatusMessage = "Saved locally (upload failed)"
                        alertMessage = "Build saved locally!\nUPT ID: \(uniqueID)\n⚠️ Upload failed: \(error.localizedDescription)\n\nYou can retry from the Archive."
                    }
                } else {
                    try await dataService.saveBuild(record, syncStatus: "pending")
                    saveProgress = 1.0
                    saveStatusMessage = "Saved locally!"
                    alertMessage = "Build saved locally!\nUPT ID: \(uniqueID)\n⚠️ No Google Sheets URL configured. You can retry sync from the Archive."
                }

                clearForm()
            } catch {
                saveProgress = 1.0
                saveStatusMessage = "Save failed"
                print("❌ Failed to save build: \(error.localizedDescription)")
                alertMessage = "Failed to save build: \(error.localizedDescription)"
            }

            try? await Task.sleep(nanoseconds: 600_000_000)
            isSaving = false
            saveProgress = 0
            saveStatusMessage = ""
            showingAlert = true
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
}
