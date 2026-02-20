//
//  ArchiveViewModel.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//


import Foundation
import CoreData
import Combine

class ArchiveViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var showingSyncAlert = false
    @Published var syncAlertMessage = ""
    @Published var isSyncing = false
    
    private let dataService: DataServiceProtocol
    private let sheetsService: GoogleSheetsServiceProtocol
    
    init(dataService: DataServiceProtocol = DataService(),
         sheetsService: GoogleSheetsServiceProtocol = GoogleSheetsService()) {
        self.dataService = dataService
        self.sheetsService = sheetsService
    }
    
    func filterBuilds(_ builds: [BuildEntity]) -> [BuildEntity] {
        if searchText.isEmpty {
            return builds
        } else {
            return builds.filter {
                ($0.uniqueID?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                ($0.bmvSerialNumber?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                ($0.builderInitials?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    func deleteBuilds(at offsets: IndexSet, from builds: [BuildEntity], context: NSManagedObjectContext) {
        offsets.map { builds[$0] }.forEach { build in
            dataService.deleteBuild(build, context: context)
        }
    }
    
    func generateCSV(from builds: [BuildEntity]) -> String {
        var csv = "Unique ID,BMV Serial Number,BMV PIN,BMV PUK,Orion Serial Number,Orion PIN,Orion Charge Rate,MPPT Serial Number,MPPT PIN,Shore Charger Serial Number,Builder Initials,Build Date,Tester Initials,Test Date,Created At\n"
        
        for build in builds {
            let uniqueID = build.uniqueID ?? ""
            let bmvSN = build.bmvSerialNumber ?? ""
            let bmvPIN = build.bmvPIN ?? ""
            let bmvPUK = build.bmvPUK ?? ""
            let orionSN = build.orionSerialNumber ?? ""
            let orionPIN = build.orionPIN ?? ""
            let orionChargeRate = build.orionChargeRate ?? ""
            let mpptSN = build.mpptSerialNumber ?? ""
            let mpptPIN = build.mpptPIN ?? ""
            let shoreChargerSerialNumber = build.shoreChargerSerialNumber ?? ""
            let builderInit = build.builderInitials ?? ""
            let buildDateStr = build.buildDate?.formatted(date: .abbreviated, time: .omitted) ?? ""
            let testerInit = build.testerInitials ?? ""
            let testDateStr = build.testDate?.formatted(date: .abbreviated, time: .omitted) ?? ""
            let createdStr = build.createdAt?.formatted(date: .abbreviated, time: .standard) ?? ""
            
            let row = "\(uniqueID),\(bmvSN),\(bmvPIN),\(bmvPUK),\(orionSN),\(orionPIN),\(orionChargeRate),\(mpptSN),\(mpptPIN),\(shoreChargerSerialNumber),\(builderInit),\(buildDateStr),\(testerInit),\(testDateStr),\(createdStr)\n"
            csv += row
        }
        
        return csv
    }
    
    // MARK: - Sync Retry Functions
    
    /// Retry syncing a single build to Google Sheets
    func retrySyncBuild(_ build: BuildEntity, sheetsURL: String) {
        guard !sheetsURL.trimmingCharacters(in: .whitespaces).isEmpty else {
            syncAlertMessage = "Google Sheets URL is not configured. Please set it in Settings."
            showingSyncAlert = true
            return
        }
        
        let record = buildRecordFrom(build)
        
        Task {
            await MainActor.run {
                isSyncing = true
            }
            
            do {
                try await sheetsService.uploadBuild(record, to: sheetsURL)
                await MainActor.run {
                    dataService.updateSyncStatus(build, status: "synced", error: nil)
                    syncAlertMessage = "✅ Build \(build.uniqueID ?? "Unknown") synced successfully!"
                    showingSyncAlert = true
                    isSyncing = false
                }
            } catch {
                await MainActor.run {
                    dataService.updateSyncStatus(build, status: "failed", error: error.localizedDescription)
                    syncAlertMessage = "❌ Sync failed for \(build.uniqueID ?? "Unknown"): \(error.localizedDescription)"
                    showingSyncAlert = true
                    isSyncing = false
                }
            }
        }
    }
    
    /// Retry syncing all pending/failed builds
    func syncAllPendingBuilds(_ builds: [BuildEntity], sheetsURL: String) {
        guard !sheetsURL.trimmingCharacters(in: .whitespaces).isEmpty else {
            syncAlertMessage = "Google Sheets URL is not configured. Please set it in Settings."
            showingSyncAlert = true
            return
        }
        
        let pendingBuilds = builds.filter { $0.syncStatus == "pending" || $0.syncStatus == "failed" }
        
        guard !pendingBuilds.isEmpty else {
            syncAlertMessage = "No pending builds to sync."
            showingSyncAlert = true
            return
        }
        
        Task {
            await MainActor.run {
                isSyncing = true
            }
            
            var successCount = 0
            var failCount = 0
            
            for build in pendingBuilds {
                let record = buildRecordFrom(build)
                
                do {
                    try await sheetsService.uploadBuild(record, to: sheetsURL)
                    await MainActor.run {
                        dataService.updateSyncStatus(build, status: "synced", error: nil)
                    }
                    successCount += 1
                } catch {
                    await MainActor.run {
                        dataService.updateSyncStatus(build, status: "failed", error: error.localizedDescription)
                    }
                    failCount += 1
                }
                
                // Small delay between uploads to avoid overwhelming the server
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            }
            
            await MainActor.run {
                if failCount == 0 {
                    syncAlertMessage = "✅ Successfully synced all \(successCount) builds!"
                } else {
                    syncAlertMessage = "Sync completed:\n✅ Success: \(successCount)\n❌ Failed: \(failCount)"
                }
                showingSyncAlert = true
                isSyncing = false
            }
        }
    }
    
    /// Convert BuildEntity back to BuildRecord for uploading
    private func buildRecordFrom(_ entity: BuildEntity) -> BuildRecord {
        BuildRecord(
            id: entity.id ?? UUID(),
            uniqueID: entity.uniqueID ?? "",
            bmvSerialNumber: entity.bmvSerialNumber ?? "",
            bmvPIN: entity.bmvPIN ?? "",
            bmvPUK: entity.bmvPUK ?? "",
            orionSerialNumber: entity.orionSerialNumber ?? "",
            orionPIN: entity.orionPIN ?? "",
            orionChargeRate: entity.orionChargeRate ?? "",
            mpptSerialNumber: entity.mpptSerialNumber ?? "",
            mpptPIN: entity.mpptPIN ?? "",
            shoreChargerSerialNumber: entity.shoreChargerSerialNumber ?? "",
            builderInitials: entity.builderInitials ?? "",
            buildDate: entity.buildDate ?? Date(),
            testerInitials: entity.testerInitials ?? "",
            testDate: entity.testDate ?? Date(),
            createdAt: entity.createdAt ?? Date()
        )
    }
}

