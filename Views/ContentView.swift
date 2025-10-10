//
//  ContentView.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//


import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            BuildEntryView()
                .tabItem {
                    Label("New Build", systemImage: "plus.circle.fill")
                }
                .tag(0)
            
            ArchiveView()
                .tabItem {
                    Label("Archive", systemImage: "archivebox.fill")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
    }
}