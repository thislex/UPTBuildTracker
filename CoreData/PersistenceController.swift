//
//  PersistenceController.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//


import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "UPTBuildTracker")  // ← Changed this
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}