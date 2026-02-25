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
    @State private var showBMVScanner = false
    @State private var showOrionScanner = false
    @State private var showMPPTScanner = false
    @State private var showShoreChargerScanner = false
    
    @FocusState private var focusedField: FormField?
    
    enum FormField: Hashable {
        case uniqueID
        case bmvSerial, bmvPUK
        case orionSerial
        case mpptSerial
        case shoreChargerSerial
        case builderInitials
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Product Information")) {
                    TextField("UPT ID", text: $viewModel.uniqueID)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .uniqueID)
                }
                
                Section(header: Text("Victron BMV")) {
                    SerialNumberField(
                        title: "Serial Number",
                        serialNumber: $viewModel.bmvSerialNumber,
                        onScanTapped: { showBMVScanner = true },
                        focused: $focusedField,
                        focusValue: .bmvSerial
                    )
                    
                    PINTextField(title: "PIN Code", pin: $viewModel.bmvPIN)
                    
                    TextField("PUK", text: $viewModel.bmvPUK)
                        .autocapitalization(.allCharacters)
                        .focused($focusedField, equals: .bmvPUK)
                }
                
                Section(header: Text("Victron Orion 12/12 50A")) {
                    SerialNumberField(
                        title: "Serial Number",
                        serialNumber: $viewModel.orionSerialNumber,
                        onScanTapped: { showOrionScanner = true },
                        focused: $focusedField,
                        focusValue: .orionSerial
                    )
                    
                    PINTextField(title: "PIN Code", pin: $viewModel.orionPIN)
                    
                    Picker("Charge Rate", selection: $viewModel.orionChargeRate) {
                        Text("18A").tag("18A")
                        Text("50A").tag("50A")
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Victron MPPT 75/15")) {
                    SerialNumberField(
                        title: "Serial Number",
                        serialNumber: $viewModel.mpptSerialNumber,
                        onScanTapped: { showMPPTScanner = true },
                        focused: $focusedField,
                        focusValue: .mpptSerial
                    )
                    
                    PINTextField(title: "PIN Code", pin: $viewModel.mpptPIN)
                }
                
                Section(header: Text("Shore Charger")) {
                    SerialNumberField(
                        title: "Serial Number",
                        serialNumber: $viewModel.shoreChargerSerialNumber,
                        onScanTapped: { showShoreChargerScanner = true },
                        focused: $focusedField,
                        focusValue: .shoreChargerSerial
                    )
                }
                
                Section(header: Text("Builder Information")) {
                    TextField("Builder Initials", text: $viewModel.builderInitials)
                        .autocapitalization(.allCharacters)
                        .focused($focusedField, equals: .builderInitials)
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
            .scrollDismissesKeyboard(.interactively) // Dismiss keyboard on scroll
            // MARK: - Keyboard Toolbar
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil // Dismisses keyboard
                    }
                    .fontWeight(.semibold)
                }
            }
            // MARK: - Scanner Sheets
            .sheet(isPresented: $showBMVScanner) {
                SimpleBarcodeScanner(scannedCode: $viewModel.bmvSerialNumber)
            }
            .sheet(isPresented: $showOrionScanner) {
                SimpleBarcodeScanner(scannedCode: $viewModel.orionSerialNumber)
            }
            .sheet(isPresented: $showMPPTScanner) {
                SimpleBarcodeScanner(scannedCode: $viewModel.mpptSerialNumber)
            }
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

// MARK: - Number Row Accessory
struct NumberRowAccessory: View {
    let onDone: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"], id: \.self) { number in
                    Button(number) {
                        // Insert the number at cursor position
                        guard let keyWindow = UIApplication.shared.connectedScenes
                            .compactMap({ $0 as? UIWindowScene })
                            .flatMap({ $0.windows })
                            .first(where: { $0.isKeyWindow }),
                              let textField = keyWindow.firstResponder as? UITextField else {
                            return
                        }
                        textField.insertText(number)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle(radius: 8))
                }
                
                Spacer()
                
                Button {
                    onDone()
                } label: {
                    Text("Done")
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 8))
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 44)
        .background(.bar)
    }
}

// Helper extension to find first responder
extension UIResponder {
    static var firstResponder: UIResponder? {
        var responder: UIResponder?
        let block: (Any?, UnsafeMutablePointer<ObjCBool>) -> Void = { obj, stop in
            if let obj = obj as? UIResponder, obj.isFirstResponder {
                responder = obj
                stop.pointee = true
            }
        }
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:_:)), to: nil, from: (block as Any, UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)), for: nil)
        return responder
    }
    
    @objc private func findFirstResponder(_ sender: Any, _ stop: UnsafeMutablePointer<ObjCBool>) {
        if self.isFirstResponder {
            (sender as? (Any?, UnsafeMutablePointer<ObjCBool>) -> Void)?(self, stop)
        }
    }
}

extension UIWindow {
    var firstResponder: UIResponder? {
        findFirstResponder(in: self)
    }
    
    private func findFirstResponder(in view: UIView) -> UIResponder? {
        if view.isFirstResponder {
            return view
        }
        for subview in view.subviews {
            if let responder = findFirstResponder(in: subview) {
                return responder
            }
        }
        return nil
    }
}

#Preview {
    BuildEntryView()
}
