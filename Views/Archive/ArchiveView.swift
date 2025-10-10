//
//  ArchiveView.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//


import SwiftUI
import CoreData

struct ArchiveView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = ArchiveViewModel()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BuildEntity.createdAt, ascending: false)],
        animation: .default)
    private var builds: FetchedResults<BuildEntity>
    
    var filteredBuilds: [BuildEntity] {
        viewModel.filterBuilds(Array(builds))
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredBuilds, id: \.id) { build in
                    NavigationLink(destination: BuildDetailView(build: build)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(build.uniqueID ?? "Unknown")
                                .font(.headline)
                            Text("BMV: \(build.bmvSerialNumber ?? "N/A")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Builder: \(build.builderInitials ?? "N/A") • \(build.buildDate?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete { offsets in
                    viewModel.deleteBuilds(at: offsets, from: filteredBuilds, context: viewContext)
                }
            }
            .navigationTitle("Build Archive")
            .searchable(text: $viewModel.searchText, prompt: "Search builds...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { exportToCSV() }) {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    private func exportToCSV() {
        let csvString = viewModel.generateCSV(from: Array(builds))
        let activityVC = UIActivityViewController(activityItems: [csvString], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}