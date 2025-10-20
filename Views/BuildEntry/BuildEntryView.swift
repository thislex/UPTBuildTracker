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
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Product Information")) {
                    TextField("UPT ID", text: $viewModel.uniqueID)
                }
                
                Section(header: Text("Victron BMV")) {
                    HStack {
                        TextField("Serial Number", text: $viewModel.bmvSerialNumber)
                            .autocapitalization(.allCharacters)
                        Button(action: { viewModel.scanSerial(for: .bmv) }) {
                            Image(systemName: "camera.fill")
                        }
                    }
                    TextField("PIN Code", text: $viewModel.bmvPIN)
                        .keyboardType(.numberPad)
                        .onChange(of: viewModel.bmvPIN) { oldValue, newValue in
                            // Keep only numeric characters and limit to 6 digits
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered.count > 6 {
                                viewModel.bmvPIN = String(filtered.prefix(6))
                            } else if filtered != newValue {
                                viewModel.bmvPIN = filtered
                            }
                        }
                        .overlay(alignment: .trailing) {
                            if !viewModel.bmvPIN.isEmpty {
                                Image(systemName: viewModel.bmvPIN.count == 6 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                    .foregroundStyle(viewModel.bmvPIN.count == 6 ? .green : .orange)
                                    .padding(.trailing, 8)
                            }
                        }
                    TextField("PUK", text: $viewModel.bmvPUK)
                        .autocapitalization(.allCharacters)
                }
                
                Section(header: Text("Victron Orion 12/12 50A")) {
                    HStack {
                        TextField("Serial Number", text: $viewModel.orionSerialNumber)
                            .autocapitalization(.allCharacters)
                        Button(action: { viewModel.scanSerial(for: .orion) }) {
                            Image(systemName: "camera.fill")
                        }
                    }
                    TextField("PIN Code", text: $viewModel.orionPIN)
                        .keyboardType(.numberPad)
                        .onChange(of: viewModel.orionPIN) { oldValue, newValue in
                            // Keep only numeric characters and limit to 6 digits
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered.count > 6 {
                                viewModel.orionPIN = String(filtered.prefix(6))
                            } else if filtered != newValue {
                                viewModel.orionPIN = filtered
                            }
                        }
                        .overlay(alignment: .trailing) {
                            if !viewModel.orionPIN.isEmpty {
                                Image(systemName: viewModel.orionPIN.count == 6 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                    .foregroundStyle(viewModel.orionPIN.count == 6 ? .green : .orange)
                                    .padding(.trailing, 8)
                            }
                        }
                    Picker("Charge Rate", selection: $viewModel.orionChargeRate) {
                        Text("18A").tag("18A")
                        Text("50A").tag("50A")
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Victron MPPT 75/15")) {
                    HStack {
                        TextField("Serial Number", text: $viewModel.mpptSerialNumber)
                            .autocapitalization(.allCharacters)
                        Button(action: { viewModel.scanSerial(for: .mppt) }) {
                            Image(systemName: "camera.fill")
                        }
                    }
                    TextField("PIN Code", text: $viewModel.mpptPIN)
                        .keyboardType(.numberPad)
                        .onChange(of: viewModel.mpptPIN) { oldValue, newValue in
                            // Keep only numeric characters and limit to 6 digits
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered.count > 6 {
                                viewModel.mpptPIN = String(filtered.prefix(6))
                            } else if filtered != newValue {
                                viewModel.mpptPIN = filtered
                            }
                        }
                        .overlay(alignment: .trailing) {
                            if !viewModel.mpptPIN.isEmpty {
                                Image(systemName: viewModel.mpptPIN.count == 6 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                    .foregroundStyle(viewModel.mpptPIN.count == 6 ? .green : .orange)
                                    .padding(.trailing, 8)
                            }
                        }
                }
                
                Section(header: Text("Shore Charger")) {
                    HStack {
                        TextField("Serial Number", text: $viewModel.shoreChargerSerialNumber)
                            .autocapitalization(.allCharacters)
                        Button(action: { viewModel.scanSerial(for: .shoreCharger) }) {
                            Image(systemName: "camera.fill")
                        }
                    }
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
            .sheet(isPresented: $viewModel.showingScanner) {
                CameraScannerView(
                    scannedText: viewModel.getBindingForScanField(),
                    isPresented: $viewModel.showingScanner
                )
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
