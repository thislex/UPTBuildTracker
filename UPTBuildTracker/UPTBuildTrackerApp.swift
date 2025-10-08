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
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
