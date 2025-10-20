//
//  CameraScannerView.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/9/25.
//


import SwiftUI

struct CameraScannerView: View {
    @Binding var scannedText: String
    @Binding var isPresented: Bool
    @State private var showManualEntry = false
    @State private var manualText = ""
    
    var body: some View {
        ZStack {
            // Barcode scanner fills the screen
            BarcodeScannerView(scannedCode: $scannedText, isPresented: $isPresented)
                .edgesIgnoringSafeArea(.all)
            
            // Manual entry button at bottom
            VStack {
                Spacer()
                
                Button {
                    showManualEntry = true
                } label: {
                    Label("Type Manually", systemImage: "keyboard")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showManualEntry) {
            ManualEntryView(text: $manualText, onSave: {
                scannedText = manualText.uppercased()
                isPresented = false
            })
        }
    }
}

struct ManualEntryView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var text: String
    var onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter Serial Number")) {
                    TextField("Serial Number", text: $text)
                        .autocapitalization(.allCharacters)
                        .disableAutocorrection(true)
                        .font(.system(.body, design: .monospaced))
                    
                    Text("Example: HQ2524MJ46G")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Button {
                        onSave()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Use This Serial Number")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(text.isEmpty)
                }
            }
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}