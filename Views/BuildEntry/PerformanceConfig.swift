//
//  PerformanceConfig.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/20/25.
//

import SwiftUI
import AVFoundation

enum PerformanceConfig {
    // Debounce time for text field validation
    static let validationDebounceTime: TimeInterval = 0.3
    
    // Camera session configuration
    static let cameraSessionPreset = AVCaptureSession.Preset.medium
    
    // UI refresh rates
    static let animationDuration: TimeInterval = 0.25
    
    // Cache settings
    static let maxCachedBuilds = 100
}

// MARK: - View Modifiers for Performance
extension View {
    /// Optimized text field for serial numbers
    func serialNumberStyle() -> some View {
        self
            .autocapitalization(.allCharacters)
            .disableAutocorrection(true)
            .font(.system(.body, design: .monospaced))
    }
    
    /// Optimized for PIN entry
    func pinStyle() -> some View {
        self
            .keyboardType(.numberPad)
            .font(.system(.body, design: .monospaced))
    }
}