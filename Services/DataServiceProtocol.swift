//
//  DataServiceProtocol.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//


import CoreData

protocol DataServiceProtocol {
    func saveBuild(_ record: BuildRecord, syncStatus: String)
    func deleteBuild(_ build: BuildEntity, context: NSManagedObjectContext)
    func updateSyncStatus(_ build: BuildEntity, status: String, error: String?)
}

class DataService: DataServiceProtocol {
    func saveBuild(_ record: BuildRecord, syncStatus: String = "pending") {
        let context = PersistenceController.shared.container.viewContext
        let entity = BuildEntity(context: context)
        entity.id = record.id
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
        
        try? context.save()
    }
    
    func deleteBuild(_ build: BuildEntity, context: NSManagedObjectContext) {
        context.delete(build)
        try? context.save()
    }
    
    func updateSyncStatus(_ build: BuildEntity, status: String, error: String?) {
        build.syncStatus = status
        build.lastSyncAttempt = Date()
        build.syncError = error
        
        if let context = build.managedObjectContext {
            try? context.save()
        }
    }
}
