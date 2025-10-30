//
//  BuildEntryView.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//


import SwiftUI

struct BuildEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = BuildEntryViewModel()
    @AppStorage("googleSheetsURL") private var sheetsURL = ""
    @State private var showShoreChargerScanner = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Product Information")) {
                    TextField("UPT ID", text: $viewModel.uniqueID)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Victron BMV")) {
                    TextField("Serial Number", text: $viewModel.bmvSerialNumber)
                        .autocapitalization(.allCharacters)
                    
                    PINTextField(title: "PIN Code", pin: $viewModel.bmvPIN)
                    
                    TextField("PUK", text: $viewModel.bmvPUK)
                        .autocapitalization(.allCharacters)
                }
                
                Section(header: Text("Victron Orion 12/12 50A")) {
                    TextField("Serial Number", text: $viewModel.orionSerialNumber)
                        .autocapitalization(.allCharacters)
                    
                    PINTextField(title: "PIN Code", pin: $viewModel.orionPIN)
                    
                    Picker("Charge Rate", selection: $viewModel.orionChargeRate) {
                        Text("18A").tag("18A")
                        Text("50A").tag("50A")
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Victron MPPT 75/15")) {
                    TextField("Serial Number", text: $viewModel.mpptSerialNumber)
                        .autocapitalization(.allCharacters)
                    
                    PINTextField(title: "PIN Code", pin: $viewModel.mpptPIN)
                }
                
                Section(header: Text("Shore Charger")) {
                    SerialNumberField(
                        title: "Serial Number",
                        serialNumber: $viewModel.shoreChargerSerialNumber,
                        onScanTapped: { showShoreChargerScanner = true }
                    )
                }
                
                Section(header: Text("Builder Information")) {
                    TextField("Builder Initials", text: $viewModel.builderInitials)
                        .autocapitalization(.allCharacters)
                    DatePicker("Build Date", selection: $viewModel.buildDate, displayedComponents: .date)
                }
                
                Section {
                    HStack(spacing: 16) {
                        Button(action: { viewModel.saveBuild(sheetsURL: sheetsURL) }) {
                            Label("Save Build", systemImage: "checkmark.circle.fill")
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(UIColor.label))
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!viewModel.isFormValid)
                        
                        Button(action: viewModel.showClearConfirmation) {
                            Label("Clear Form", systemImage: "trash.fill")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.bordered)
                        .foregroundStyle(.red)
                    }
                }

                
                VStack(spacing: 4) {
                    Text("Made by Lexter S. Tapawan")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text("UPT Build Tracker™ 2025")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .navigationTitle("New Build Entry")
            .sheet(isPresented: $showShoreChargerScanner) {
                SimpleBarcodeScanner(scannedCode: $viewModel.shoreChargerSerialNumber)
            }
            .alert("Build Entry", isPresented: $viewModel.showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
            .alert("Clear Form", isPresented: $viewModel.showingClearConfirmation) {
                Button("Yes", role: .destructive) {
                    viewModel.clearForm()
                }
                Button("No", role: .cancel) { }
            } message: {
                Text("Are you sure you want to clear all form data? This action cannot be undone.")
            }
        }
    }
}

#Preview {
    BuildEntryView()
}
