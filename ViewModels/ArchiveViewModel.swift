//
//  ArchiveViewModel.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//


import Foundation
import CoreData

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
        var csv = "Unique ID,BMV Serial Number,BMV PIN,Orion Serial Number,Orion PIN,MPPT Serial Number,MPPT PIN,Builder Initials,Build Date,Tester Initials,Test Date,Created At\n"
        
        for build in builds {
            let row = [
                build.uniqueID ?? "",
                build.bmvSerialNumber ?? "",
                build.bmvPIN ?? "",
                build.orionSerialNumber ?? "",
                build.orionPIN ?? "",
                build.mpptSerialNumber ?? "",
                build.mpptPIN ?? "",
                build.builderInitials ?? "",
                build.buildDate?.formatted(date: .abbreviated, time: .omitted) ?? "",
                build.testerInitials ?? "",
                build.testDate?.formatted(date: .abbreviated, time: .omitted) ?? "",
                build.createdAt?.formatted(date: .abbreviated, time: .standard) ?? ""
            ].joined(separator: ",")
            csv += row + "\n"
        }
        
        return csv
    }
}