//
//  CameraScannerView.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//


import SwiftUI

struct CameraScannerView: View {
    @Binding var scannedText: String
    @Binding var isPresented: Bool
    @StateObject private var viewModel = CameraScannerViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                CameraView(recognizedText: $viewModel.recognizedText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                if !viewModel.recognizedText.isEmpty {
                    VStack(spacing: 12) {
                        Text("Detected: \(viewModel.recognizedText)")
                            .padding()
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(8)
                        
                        HStack(spacing: 20) {
                            Button("Use This") {
                                scannedText = viewModel.recognizedText
                                isPresented = false
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Scan Again") {
                                viewModel.resetScan()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Scan Serial Number")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}