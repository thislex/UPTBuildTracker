//
//  BuildDetailView.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//


import SwiftUI

struct BuildDetailView: View {
    let build: BuildEntity
    
    var body: some View {
        Form {
            Section("Product Information") {
                DetailRow(label: "Unique ID", value: build.uniqueID ?? "N/A")
            }
            
            Section("BMV Serial Number") {
                DetailRow(label: "Serial Number", value: build.bmvSerialNumber ?? "N/A")
                DetailRow(label: "PIN", value: build.bmvPIN ?? "N/A")
            }
            
            Section("Orion Serial Number") {
                DetailRow(label: "Serial Number", value: build.orionSerialNumber ?? "N/A")
                DetailRow(label: "PIN", value: build.orionPIN ?? "N/A")
            }
            
            Section("MPPT Serial Number") {
                DetailRow(label: "Serial Number", value: build.mpptSerialNumber ?? "N/A")
                DetailRow(label: "PIN", value: build.mpptPIN ?? "N/A")
            }
            
            Section("Builder Information") {
                DetailRow(label: "Initials", value: build.builderInitials ?? "N/A")
                DetailRow(label: "Date", value: build.buildDate?.formatted(date: .long, time: .omitted) ?? "N/A")
            }
            
            Section("Tester Information") {
                DetailRow(label: "Initials", value: build.testerInitials ?? "N/A")
                DetailRow(label: "Date", value: build.testDate?.formatted(date: .long, time: .omitted) ?? "N/A")
            }
            
            Section("Metadata") {
                DetailRow(label: "Created", value: build.createdAt?.formatted(date: .long, time: .standard) ?? "N/A")
            }
        }
        .navigationTitle("Build Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}