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
    @Published var showingDeleteError = false
    @Published var deleteErrorMessage = ""
    
    private let dataService: DataServiceProtocol
    private let sheetsService: GoogleSheetsServiceProtocol
    
    init(dataService: DataServiceProtocol = DataService(),
         sheetsService: GoogleSheetsServiceProtocol = GoogleSheetsService()) {
        self.dataService = dataService
        self.sheetsService = sheetsService
    }
    
    func filterBuilds(_ builds: [BuildEntity]) -> [BuildEntity] {
        // Filter out deleted or faulted objects
        let validBuilds = builds.filter { !$0.isDeleted && !$0.isFault }
        
        if searchText.isEmpty {
            return validBuilds
        } else {
            return validBuilds.filter {
                ($0.uniqueID?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                ($0.bmvSerialNumber?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                ($0.builderInitials?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    func deleteBuilds(at offsets: IndexSet, from builds: [BuildEntity], context: NSManagedObjectContext) {
        // Ensure we're on the main thread
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.deleteBuilds(at: offsets, from: builds, context: context)
            }
            return
        }
        
        // Collect the builds to delete first to avoid index issues
        let buildsToDelete = offsets.map { builds[$0] }
        
        // Delete each build
        for build in buildsToDelete {
            // Verify the build still exists in the context
            guard !build.isDeleted, build.managedObjectContext != nil else {
                print("⚠️ Skipping already deleted or detached build")
                continue
            }
            context.delete(build)
        }
        
        // Save the context
        do {
            if context.hasChanges {
                try context.save()
                print("✅ Successfully deleted \(buildsToDelete.count) build(s)")
            }
        } catch {
            print("❌ Failed to delete builds: \(error.localizedDescription)")
            let nsError = error as NSError
            print("Error details: \(nsError.userInfo)")
            
            // Rollback to prevent inconsistent state
            context.rollback()
            
            // Show error to user
            self.deleteErrorMessage = "Failed to delete: \(error.localizedDescription)"
            self.showingDeleteError = true
        }
    }
    
    func generateCSV(from builds: [BuildEntity]) -> String {
        var csv = "Unique ID,BMV Serial Number,BMV PIN,BMV PUK,Orion Serial Number,Orion PIN,Orion Charge Rate,MPPT Serial Number,MPPT PIN,Shore Charger Serial Number,Builder Initials,Build Date,Tester Initials,Test Date,Created At\n"
        
        for build in builds {
            // Skip deleted or faulted objects
            guard !build.isDeleted, !build.isFault else {
                print("⚠️ Skipping deleted or faulted build in CSV export")
                continue
            }
            
            // Safely escape CSV values that might contain commas
            let uniqueID = escapeCSV(build.uniqueID ?? "")
            let bmvSN = escapeCSV(build.bmvSerialNumber ?? "")
            let bmvPIN = escapeCSV(build.bmvPIN ?? "")
            let bmvPUK = escapeCSV(build.bmvPUK ?? "")
            let orionSN = escapeCSV(build.orionSerialNumber ?? "")
            let orionPIN = escapeCSV(build.orionPIN ?? "")
            let orionChargeRate = escapeCSV(build.orionChargeRate ?? "")
            let mpptSN = escapeCSV(build.mpptSerialNumber ?? "")
            let mpptPIN = escapeCSV(build.mpptPIN ?? "")
            let shoreChargerSerialNumber = escapeCSV(build.shoreChargerSerialNumber ?? "")
            let builderInit = escapeCSV(build.builderInitials ?? "")
            let buildDateStr = build.buildDate?.formatted(date: .abbreviated, time: .omitted) ?? ""
            let testerInit = escapeCSV(build.testerInitials ?? "")
            let testDateStr = build.testDate?.formatted(date: .abbreviated, time: .omitted) ?? ""
            let createdStr = build.createdAt?.formatted(date: .abbreviated, time: .standard) ?? ""
            
            let row = "\(uniqueID),\(bmvSN),\(bmvPIN),\(bmvPUK),\(orionSN),\(orionPIN),\(orionChargeRate),\(mpptSN),\(mpptPIN),\(shoreChargerSerialNumber),\(builderInit),\(buildDateStr),\(testerInit),\(testDateStr),\(createdStr)\n"
            csv += row
        }
        
        return csv
    }
    
    /// Escape CSV values that contain commas, quotes, or newlines
    private func escapeCSV(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return value
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
        
        Task { @MainActor in
            isSyncing = true
            
            do {
                try await sheetsService.uploadBuild(record, to: sheetsURL)
                try await dataService.updateSyncStatus(build, status: "synced", error: nil)
                syncAlertMessage = "✅ Build \(build.uniqueID ?? "Unknown") synced successfully!"
                showingSyncAlert = true
            } catch {
                do {
                    try await dataService.updateSyncStatus(build, status: "failed", error: error.localizedDescription)
                } catch {
                    print("❌ Failed to update sync status: \(error.localizedDescription)")
                }
                syncAlertMessage = "❌ Sync failed for \(build.uniqueID ?? "Unknown"): \(error.localizedDescription)"
                showingSyncAlert = true
            }
            
            isSyncing = false
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
        
        Task { @MainActor in
            isSyncing = true
            
            var successCount = 0
            var failCount = 0
            
            for build in pendingBuilds {
                let record = buildRecordFrom(build)
                
                do {
                    try await sheetsService.uploadBuild(record, to: sheetsURL)
                    try await dataService.updateSyncStatus(build, status: "synced", error: nil)
                    successCount += 1
                } catch {
                    do {
                        try await dataService.updateSyncStatus(build, status: "failed", error: error.localizedDescription)
                    } catch {
                        print("❌ Failed to update sync status: \(error.localizedDescription)")
                    }
                    failCount += 1
                }
                
                // Small delay between uploads to avoid overwhelming the server
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            }
            
            if failCount == 0 {
                syncAlertMessage = "✅ Successfully synced all \(successCount) builds!"
            } else {
                syncAlertMessage = "Sync completed:\n✅ Success: \(successCount)\n❌ Failed: \(failCount)"
            }
            showingSyncAlert = true
            isSyncing = false
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

