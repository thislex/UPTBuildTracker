//
//  SettingsView.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//


import SwiftUI

struct SettingsView: View {
    var onGoHome: (() -> Void)? = nil

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
                        Text("2.0.0")
                            .foregroundColor(.secondary)
                    }
                }

                if let goHome = onGoHome {
                    Section {
                        Button(role: .destructive) {
                            goHome()
                        } label: {
                            Label("Change Product", systemImage: "house.fill")
                                .frame(maxWidth: .infinity)
                        }
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
