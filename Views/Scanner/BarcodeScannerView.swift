//
//  BarcodeScannerView.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/9/25.
//


import SwiftUI
import AVFoundation

struct BarcodeScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let scanner = ScannerViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(scannedCode: $scannedCode, isPresented: $isPresented)
    }
    
    class Coordinator: NSObject, ScannerViewControllerDelegate {
        @Binding var scannedCode: String
        @Binding var isPresented: Bool
        
        init(scannedCode: Binding<String>, isPresented: Binding<Bool>) {
            _scannedCode = scannedCode
            _isPresented = isPresented
        }
        
        func didFind(code: String) {
            scannedCode = code
            isPresented = false
        }
        
        func didCancel() {
            isPresented = false
        }
    }
}

protocol ScannerViewControllerDelegate: AnyObject {
    func didFind(code: String)
    func didCancel()
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    weak var delegate: ScannerViewControllerDelegate?
    
    // Tap-to-scan properties
    private var detectedCode: String?
    private var isReadyToScan = true
    private var scanningRect: CGRect = .zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        captureSession = AVCaptureSession()
        
        // Optimize capture session for better performance
        captureSession.sessionPreset = .medium // Use medium instead of high for better performance
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            failed()
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            failed()
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // Support all common barcode types
            metadataOutput.metadataObjectTypes = [
                .ean8, .ean13, .pdf417,
                .qr, .code39, .code39Mod43,
                .code93, .code128, .upce,
                .aztec, .dataMatrix, .interleaved2of5,
                .itf14
            ]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // Add viewfinder overlay
        let overlayView = UIView(frame: CGRect(x: 0, y: 0, width: 280, height: 150))
        overlayView.center = view.center
        overlayView.layer.borderColor = UIColor.systemGreen.cgColor
        overlayView.layer.borderWidth = 3
        overlayView.layer.cornerRadius = 12
        overlayView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        view.addSubview(overlayView)
        
        // Store the scanning rectangle for bounds checking
        scanningRect = overlayView.frame
        
        // Add instruction label
        let label = UILabel()
        label.text = "Align barcode within frame"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.tag = 100 // Tag for easy reference
        view.addSubview(label)
        
        // Add scan button
        let scanButton = UIButton(type: .system)
        scanButton.setTitle("Tap to Scan", for: .normal)
        scanButton.setTitleColor(.white, for: .normal)
        scanButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.9)
        scanButton.layer.cornerRadius = 12
        scanButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        scanButton.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        scanButton.tag = 101 // Tag for easy reference
        view.addSubview(scanButton)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: 20),
            label.widthAnchor.constraint(equalToConstant: 280),
            label.heightAnchor.constraint(equalToConstant: 44),
            
            scanButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            scanButton.widthAnchor.constraint(equalToConstant: 160),
            scanButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add cancel button (top left)
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        cancelButton.layer.cornerRadius = 8
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.widthAnchor.constraint(equalToConstant: 80),
            cancelButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
        
        // Update scanning rectangle position after layout changes
        if let overlayView = view.subviews.first(where: { $0.layer.borderColor == UIColor.systemGreen.cgColor }) {
            scanningRect = overlayView.frame
        }
    }
    
    @objc func cancelTapped() {
        delegate?.didCancel()
    }
    
    @objc func scanButtonTapped() {
        // If we have a detected code, use it
        if let code = detectedCode {
            found(code: code)
        } else {
            // Provide feedback that no barcode is detected
            updateInstructionText("No barcode detected - try repositioning")
            AudioServicesPlaySystemSound(1521) // Error sound
        }
    }
    
    private func updateInstructionText(_ text: String) {
        if let label = view.viewWithTag(100) as? UILabel {
            label.text = text
            
            // Reset text after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                label.text = "Align barcode within frame"
            }
        }
    }
    
    private func updateScanButton(enabled: Bool, title: String) {
        if let button = view.viewWithTag(101) as? UIButton {
            button.isEnabled = enabled
            button.setTitle(title, for: .normal)
            button.backgroundColor = enabled ? 
                UIColor.systemBlue.withAlphaComponent(0.9) : 
                UIColor.gray.withAlphaComponent(0.7)
        }
    }
    
    private func isBarcodeReasonablyPositioned(_ readableObject: AVMetadataMachineReadableCodeObject) -> Bool {
        guard let transformedObject = previewLayer.transformedMetadataObject(for: readableObject) else {
            print("🔍 Failed to transform metadata object")
            return false
        }
        
        let barcodeBounds = transformedObject.bounds
        let viewBounds = view.bounds
        
        print("🔍 View bounds: \(viewBounds)")
        print("🔍 Barcode bounds: \(barcodeBounds)")
        
        // Very lenient check - just make sure barcode is mostly on screen and reasonably sized
        let barcodeCenter = CGPoint(x: barcodeBounds.midX, y: barcodeBounds.midY)
        
        // Check if barcode center is within the middle 80% of the screen
        let allowedRect = viewBounds.insetBy(dx: viewBounds.width * 0.1, dy: viewBounds.height * 0.1)
        let isInCenterArea = allowedRect.contains(barcodeCenter)
        
        // Check if barcode is not too small (at least 50x30 points)
        let isReasonableSize = barcodeBounds.width >= 50 && barcodeBounds.height >= 30
        
        print("🔍 Center in allowed area: \(isInCenterArea)")
        print("🔍 Reasonable size: \(isReasonableSize) (width: \(barcodeBounds.width), height: \(barcodeBounds.height))")
        
        return isInCenterArea && isReasonableSize
    }
    
    func failed() {
        let alert = UIAlertController(
            title: "Scanning Not Supported",
            message: "Your device does not support barcode scanning.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.delegate?.didCancel()
        })
        present(alert, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    deinit {
        // Clean up capture session
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        captureSession = nil
        previewLayer = nil
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // Process detected barcodes
        print("🔍 Detected \(metadataObjects.count) metadata objects")
        
        for (index, obj) in metadataObjects.enumerated() {
            if let readableObject = obj as? AVMetadataMachineReadableCodeObject {
                print("🔍 Object \(index): Type: \(readableObject.type.rawValue), Value: \(readableObject.stringValue ?? "nil")")
            }
        }
        
        // Filter for valid readable barcodes
        let validBarcodes = metadataObjects.compactMap { metadataObject -> (AVMetadataMachineReadableCodeObject, String)? in
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue, 
                  !stringValue.isEmpty else {
                return nil
            }
            return (readableObject, stringValue)
        }
        
        print("🔍 Found \(validBarcodes.count) valid barcodes")
        
        if let firstValidBarcode = validBarcodes.first {
            let (readableObject, stringValue) = firstValidBarcode
            
            // Check if this barcode is reasonably positioned (more lenient check)
            if isBarcodeReasonablyPositioned(readableObject) {
                print("✅ Barcode ready for scanning: \(stringValue)")
                
                // Store the detected code and update UI
                detectedCode = stringValue
                updateInstructionText("Barcode detected! Tap to scan")
                updateScanButton(enabled: true, title: "Scan Now")
                
                // Light haptic feedback to indicate detection
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
            } else {
                print("⚠️ Barcode detected but not well positioned")
                updateInstructionText("Move barcode closer to frame")
                updateScanButton(enabled: false, title: "Tap to Scan")
            }
        } else {
            // No valid barcodes detected
            detectedCode = nil
            updateInstructionText("Align barcode within frame")
            updateScanButton(enabled: false, title: "Tap to Scan")
        }
    }
    
    func found(code: String) {
        print("✅ Barcode scanned: \(code)")
        
        // Stop the capture session
        captureSession.stopRunning()
        
        // Strong haptic feedback for successful scan
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        delegate?.didFind(code: code)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}