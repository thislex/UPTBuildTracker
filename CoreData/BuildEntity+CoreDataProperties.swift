//
//  func.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//


import Foundation
import CoreData

extension BuildEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BuildEntity> {
        return NSFetchRequest<BuildEntity>(entityName: "BuildEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var uniqueID: String?
    @NSManaged public var bmvSerialNumber: String?
    @NSManaged public var bmvPIN: String?
    @NSManaged public var bmvPUK: String?
    @NSManaged public var orionSerialNumber: String?
    @NSManaged public var orionPIN: String?
    @NSManaged public var orionChargeRate: String?
    @NSManaged public var mpptSerialNumber: String?
    @NSManaged public var mpptPIN: String?
    @NSManaged public var shoreChargerSerialNumber: String?
    @NSManaged public var builderInitials: String?
    @NSManaged public var buildDate: Date?
    @NSManaged public var testerInitials: String?
    @NSManaged public var testDate: Date?
    @NSManaged public var createdAt: Date?
}
