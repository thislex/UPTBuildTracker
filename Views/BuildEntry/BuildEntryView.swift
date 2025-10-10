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
                    HStack {
                        TextField("Unique ID", text: $viewModel.uniqueID)
                        Button(action: viewModel.generateUniqueID) {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
                
                Section(header: Text("BMV Serial Number")) {
                    HStack {
                        TextField("Serial Number", text: $viewModel.bmvSerialNumber)
                            .autocapitalization(.allCharacters)
                        Button(action: { viewModel.scanSerial(for: .bmv) }) {
                            Image(systemName: "camera.fill")
                        }
                    }
                    TextField("PIN Code", text: $viewModel.bmvPIN)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Orion Serial Number")) {
                    HStack {
                        TextField("Serial Number", text: $viewModel.orionSerialNumber)
                            .autocapitalization(.allCharacters)
                        Button(action: { viewModel.scanSerial(for: .orion) }) {
                            Image(systemName: "camera.fill")
                        }
                    }
                    TextField("PIN Code", text: $viewModel.orionPIN)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("MPPT Serial Number")) {
                    HStack {
                        TextField("Serial Number", text: $viewModel.mpptSerialNumber)
                            .autocapitalization(.allCharacters)
                        Button(action: { viewModel.scanSerial(for: .mppt) }) {
                            Image(systemName: "camera.fill")
                        }
                    }
                    TextField("PIN Code", text: $viewModel.mpptPIN)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Builder Information")) {
                    TextField("Builder Initials", text: $viewModel.builderInitials)
                        .autocapitalization(.allCharacters)
                    DatePicker("Build Date", selection: $viewModel.buildDate, displayedComponents: .date)
                }
                
                Section(header: Text("Tester Information")) {
                    TextField("Tester Initials", text: $viewModel.testerInitials)
                        .autocapitalization(.allCharacters)
                    DatePicker("Test Date", selection: $viewModel.testDate, displayedComponents: .date)
                }
                
                Section {
                    Button(action: { viewModel.saveBuild(sheetsURL: sheetsURL) }) {
                        HStack {
                            Spacer()
                            Text("Save Build")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!viewModel.isFormValid)
                    
                    Button(action: viewModel.clearForm) {
                        HStack {
                            Spacer()
                            Text("Clear Form")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
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
        }
    }
}