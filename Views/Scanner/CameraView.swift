//
//  CameraView.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//


import SwiftUI
import AVFoundation
import Vision

struct CameraView: UIViewRepresentable {
    @Binding var recognizedText: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            return view
        }
        
        captureSession.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(output)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
        
        context.coordinator.session = captureSession
        context.coordinator.previewLayer = previewLayer
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = context.coordinator.previewLayer {
            layer.frame = uiView.bounds
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedText: $recognizedText)
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        @Binding var recognizedText: String
        var session: AVCaptureSession?
        var previewLayer: AVCaptureVideoPreviewLayer?
        private var lastProcessTime = Date()
        
        init(recognizedText: Binding<String>) {
            _recognizedText = recognizedText
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard Date().timeIntervalSince(lastProcessTime) > 0.5 else { return }
            lastProcessTime = Date()
            
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            let request = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
                
                let recognizedStrings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                
                for text in recognizedStrings {
                    let cleaned = text.replacingOccurrences(of: " ", with: "")
                    if cleaned.range(of: "^[A-Z]{2,3}\\d{4}[A-Z]{2,}[A-Z]{2,}$", options: .regularExpression) != nil {
                        DispatchQueue.main.async {
                            self.recognizedText = cleaned
                            self.session?.stopRunning()
                        }
                        return
                    }
                }
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false
            
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            try? handler.perform([request])
        }
    }
}