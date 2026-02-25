//
//  DataServiceProtocol.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//


import CoreData

protocol DataServiceProtocol {
    func saveBuild(_ record: BuildRecord, syncStatus: String) async throws
    func deleteBuild(_ build: BuildEntity, context: NSManagedObjectContext) async throws
    func updateSyncStatus(_ build: BuildEntity, status: String, error: String?) async throws
}

class DataService: DataServiceProtocol {
    
    /// Save a build record with proper error handling and thread safety
    @MainActor
    func saveBuild(_ record: BuildRecord, syncStatus: String = "pending") async throws {
        let context = PersistenceController.shared.container.viewContext
        
        // Ensure context is valid - if there are unsaved changes, save or reset them first
        if context.hasChanges {
            print("⚠️ Warning: Context has unsaved changes - rolling back")
            context.rollback()
        }
        
        // Check if entity with this ID already exists
        let fetchRequest = BuildEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", record.id as CVarArg)
        
        let existingEntities = try context.fetch(fetchRequest)
        let entity: BuildEntity
        
        if let existing = existingEntities.first {
            // Update existing entity
            print("ℹ️ Updating existing build: \(record.id)")
            entity = existing
        } else {
            // Create new entity
            print("ℹ️ Creating new build: \(record.id)")
            entity = BuildEntity(context: context)
            entity.id = record.id
        }
        
        // Update all properties
        entity.uniqueID = record.uniqueID
        entity.bmvSerialNumber = record.bmvSerialNumber
        entity.bmvPIN = record.bmvPIN
        entity.bmvPUK = record.bmvPUK
        entity.orionSerialNumber = record.orionSerialNumber
        entity.orionPIN = record.orionPIN
        entity.orionChargeRate = record.orionChargeRate
        entity.mpptSerialNumber = record.mpptSerialNumber
        entity.mpptPIN = record.mpptPIN
        entity.shoreChargerSerialNumber = record.shoreChargerSerialNumber
        entity.builderInitials = record.builderInitials
        entity.buildDate = record.buildDate
        entity.testerInitials = record.testerInitials
        entity.testDate = record.testDate
        entity.createdAt = record.createdAt
        
        // Set sync status
        entity.syncStatus = syncStatus
        entity.lastSyncAttempt = nil
        entity.syncError = nil
        
        // Validate before saving
        do {
            try entity.validateForInsert()
        } catch {
            print("❌ Validation failed: \(error.localizedDescription)")
            throw error
        }
        
        // Save with proper error handling
        do {
            if context.hasChanges {
                print("ℹ️ Saving context with changes...")
                try context.save()
                print("✅ Build saved successfully")
            } else {
                print("ℹ️ No changes to save")
            }
        } catch {
            print("❌ Failed to save build: \(error.localizedDescription)")
            let validationError = error as NSError
            print("Error details: \(validationError.userInfo)")
            // Rollback on error
            context.rollback()
            throw error
        }
    }
    
    /// Delete a build with proper error handling
    @MainActor
    func deleteBuild(_ build: BuildEntity, context: NSManagedObjectContext) async throws {
        guard context == PersistenceController.shared.container.viewContext else {
            throw NSError(domain: "DataService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Context mismatch"])
        }
        
        context.delete(build)
        
        do {
            try context.save()
        } catch {
            print("❌ Failed to delete build: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Update sync status with proper error handling
    @MainActor
    func updateSyncStatus(_ build: BuildEntity, status: String, error: String?) async throws {
        guard let context = build.managedObjectContext else {
            throw NSError(domain: "DataService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Entity has no context"])
        }
        
        build.syncStatus = status
        build.lastSyncAttempt = Date()
        build.syncError = error
        
        do {
            try context.save()
        } catch let saveError {
            print("❌ Failed to update sync status: \(saveError.localizedDescription)")
            throw saveError
        }
    }
}
