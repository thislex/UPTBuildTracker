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
        container = NSPersistentContainer(name: "UPTBuildTracker")
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // Detailed error logging
                print("❌ Core Data failed to load persistent stores")
                print("Store Description: \(storeDescription)")
                print("Error: \(error)")
                print("Error Code: \(error.code)")
                print("User Info: \(error.userInfo)")
                
                // Check for common issues
                if error.code == 134100 { // NSPersistentStoreIncompatibleVersionHashError
                    print("⚠️ Model version mismatch - the data model has changed")
                    print("⚠️ You may need to delete the app and reinstall")
                } else if error.code == 134130 { // NSMigrationMissingSourceModelError
                    print("⚠️ Migration error - missing source model")
                }
                
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        // Enable automatic merging of changes
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Log success
        print("✅ Core Data loaded successfully")
    }
    
    /// Create a background context for performing operations off the main thread
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
}
