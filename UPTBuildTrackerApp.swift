//
//  UPTBuildTrackerApp.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//


import SwiftUI
import CoreData

@main
struct UPTBuildTrackerApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .background:
                // Save any unsaved Core Data changes before the app is suspended
                persistenceController.saveIfNeeded()
            case .active where oldPhase == .background || oldPhase == .inactive:
                // Auto-sync pending builds when returning to foreground
                autoSyncPendingBuilds()
            default:
                break
            }
        }
    }
    
    private func autoSyncPendingBuilds() {
        let sheetsURL = UserDefaults.standard.string(forKey: "googleSheetsURL") ?? ""
        guard !sheetsURL.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let context = persistenceController.container.viewContext
        let request = BuildEntity.fetchRequest()
        request.predicate = NSPredicate(format: "syncStatus == %@ OR syncStatus == %@", "pending", "failed")
        
        guard let pendingBuilds = try? context.fetch(request), !pendingBuilds.isEmpty else { return }
        
        let sheetsService = GoogleSheetsService()
        let dataService = DataService()
        
        Task { @MainActor in
            for build in pendingBuilds {
                let record = BuildRecord(
                    id: build.id ?? UUID(),
                    uniqueID: build.uniqueID ?? "",
                    bmvSerialNumber: build.bmvSerialNumber ?? "",
                    bmvPIN: build.bmvPIN ?? "",
                    bmvPUK: build.bmvPUK ?? "",
                    orionSerialNumber: build.orionSerialNumber ?? "",
                    orionPIN: build.orionPIN ?? "",
                    orionChargeRate: build.orionChargeRate ?? "",
                    mpptSerialNumber: build.mpptSerialNumber ?? "",
                    mpptPIN: build.mpptPIN ?? "",
                    shoreChargerSerialNumber: build.shoreChargerSerialNumber ?? "",
                    builderInitials: build.builderInitials ?? "",
                    buildDate: build.buildDate ?? Date(),
                    testerInitials: build.testerInitials ?? "",
                    testDate: build.testDate ?? Date(),
                    createdAt: build.createdAt ?? Date()
                )
                
                do {
                    try await sheetsService.uploadBuild(record, to: sheetsURL)
                    try await dataService.updateSyncStatus(build, status: "synced", error: nil)
                } catch {
                    try? await dataService.updateSyncStatus(build, status: "failed", error: error.localizedDescription)
                }
                
                try? await Task.sleep(nanoseconds: 500_000_000)
            }
        }
    }
}
