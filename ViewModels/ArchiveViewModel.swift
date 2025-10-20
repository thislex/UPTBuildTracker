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
    
    private let dataService: DataServiceProtocol
    
    init(dataService: DataServiceProtocol = DataService()) {
        self.dataService = dataService
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
}

