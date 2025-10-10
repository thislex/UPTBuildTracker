//
//  CameraScannerViewModel.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//


import Foundation

class CameraScannerViewModel: ObservableObject {
    @Published var recognizedText = ""
    
    func resetScan() {
        recognizedText = ""
    }
}