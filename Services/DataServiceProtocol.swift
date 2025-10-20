//
//  DataServiceProtocol.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//


import CoreData

protocol DataServiceProtocol {
    func saveBuild(_ record: BuildRecord)
    func deleteBuild(_ build: BuildEntity, context: NSManagedObjectContext)
}

class DataService: DataServiceProtocol {
    func saveBuild(_ record: BuildRecord) {
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
        
        try? context.save()
    }
    
    func deleteBuild(_ build: BuildEntity, context: NSManagedObjectContext) {
        context.delete(build)
        try? context.save()
    }
}
