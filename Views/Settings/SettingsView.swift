//
//  SettingsView.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//


import SwiftUI

struct SettingsView: View {
    @AppStorage("googleSheetsURL") private var sheetsURL = ""
    @State private var showingInstructions = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Google Sheets Integration")) {
                    TextField("Apps Script Web App URL", text: $sheetsURL)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                    
                    Button("Setup Instructions") {
                        showingInstructions = true
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingInstructions) {
                GoogleSheetsInstructionsView()
            }
        }
    }
}