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
    @AppStorage("googleSheetsURL") private var sheetsURL = ""
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BuildEntity.createdAt, ascending: false)],
        animation: .default)
    private var builds: FetchedResults<BuildEntity>
    
    var filteredBuilds: [BuildEntity] {
        viewModel.filterBuilds(Array(builds))
    }
    
    var hasPendingBuilds: Bool {
        filteredBuilds.contains { $0.syncStatus == "pending" || $0.syncStatus == "failed" }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredBuilds, id: \.id) { build in
                    HStack {
                        NavigationLink(destination: BuildDetailView(build: build)) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(build.uniqueID ?? "Unknown")
                                        .font(.headline)
                                    
                                    // Show sync status indicator
                                    if build.syncStatus == "pending" {
                                        Image(systemName: "clock.arrow.circlepath")
                                            .foregroundColor(.orange)
                                            .font(.caption)
                                    } else if build.syncStatus == "failed" {
                                        Image(systemName: "exclamationmark.icloud")
                                            .foregroundColor(.red)
                                            .font(.caption)
                                    } else if build.syncStatus == "synced" {
                                        Image(systemName: "checkmark.icloud")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                    }
                                }
                                Text("BMV: \(build.bmvSerialNumber ?? "N/A")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Builder: \(build.builderInitials ?? "N/A") • \(build.buildDate?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                // Show sync error if exists
                                if let error = build.syncError, build.syncStatus == "failed" {
                                    Text("Error: \(error)")
                                        .font(.caption2)
                                        .foregroundColor(.red)
                                        .lineLimit(1)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        
                        // Retry button for failed or pending syncs
                        if build.syncStatus == "pending" || build.syncStatus == "failed" {
                            Button {
                                viewModel.retrySyncBuild(build, sheetsURL: sheetsURL)
                            } label: {
                                if viewModel.isSyncing {
                                    ProgressView()
                                } else {
                                    Image(systemName: "arrow.clockwise.circle.fill")
                                        .foregroundColor(.blue)
                                        .imageScale(.large)
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(viewModel.isSyncing)
                        }
                    }
                }
                .onDelete { offsets in
                    viewModel.deleteBuilds(at: offsets, from: filteredBuilds, context: viewContext)
                }
            }
            .navigationTitle("Build Archive")
            .searchable(text: $viewModel.searchText, prompt: "Search builds...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Sync all pending builds button
                    if hasPendingBuilds {
                        Button {
                            viewModel.syncAllPendingBuilds(filteredBuilds, sheetsURL: sheetsURL)
                        } label: {
                            if viewModel.isSyncing {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Syncing...")
                                        .font(.caption)
                                }
                            } else {
                                Label("Sync All", systemImage: "icloud.and.arrow.up")
                            }
                        }
                        .disabled(viewModel.isSyncing)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { exportToCSV() }) {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .alert("Sync Status", isPresented: $viewModel.showingSyncAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.syncAlertMessage)
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