//
//  BuildEntryView.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//

import SwiftUI

struct BuildEntryView: View {
    var onGoHome: (() -> Void)? = nil

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

    // MARK: - Form Sections

    private var productInfoSection: some View {
        Section(header: Text("Product Information")) {
            TextField("UPT ID", text: $viewModel.uniqueID)
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .uniqueID)
        }
    }

    private var bmvSection: some View {
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
    }

    private var orionSection: some View {
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
    }

    private var mpptSection: some View {
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
    }

    private var shoreChargerSection: some View {
        Section(header: Text("Shore Charger")) {
            SerialNumberField(
                title: "Serial Number",
                serialNumber: $viewModel.shoreChargerSerialNumber,
                onScanTapped: { showShoreChargerScanner = true },
                focused: $focusedField,
                focusValue: .shoreChargerSerial
            )
        }
    }

    private var builderInfoSection: some View {
        Section(header: Text("Builder Information")) {
            TextField("Builder Initials", text: $viewModel.builderInitials)
                .autocapitalization(.allCharacters)
                .focused($focusedField, equals: .builderInitials)
            DatePicker("Build Date", selection: $viewModel.buildDate, displayedComponents: .date)
        }
    }

    private var actionSection: some View {
        Section {
            HStack(spacing: 16) {
                Button(action: {
                    focusedField = nil
                    viewModel.saveBuild(sheetsURL: sheetsURL)
                }) {
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
    }

    // MARK: - Progress Overlay

    @ViewBuilder
    private var saveProgressOverlay: some View {
        if viewModel.isSaving {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("Saving Build")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    ProgressView(value: viewModel.saveProgress)
                        .progressViewStyle(.linear)
                        .tint(.accentColor)
                        .frame(width: 240)
                        .animation(.easeInOut, value: viewModel.saveProgress)

                    Text(viewModel.saveStatusMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(28)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(radius: 20)
            }
            .transition(.opacity)
        }
    }

    // MARK: - Form View

    private var formView: some View {
        Form {
            productInfoSection
            bmvSection
            orionSection
            mpptSection
            shoreChargerSection
            builderInfoSection
            actionSection

            VStack(spacing: 4) {
                Text("Built by Lexter S. Tapawan")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("CFD Build Tracker™ 2026")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .navigationTitle("New UPT Build Entry")
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            if let goHome = onGoHome {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { goHome() } label: {
                        Label("Home", systemImage: "house.fill")
                    }
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = nil }
                    .fontWeight(.semibold)
            }
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            ZStack {
                formView
                saveProgressOverlay
            }
            .animation(.easeInOut(duration: 0.25), value: viewModel.isSaving)
        }
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
                .multilineTextAlignment(.center)
        }
        .alert("Clear Form", isPresented: $viewModel.showingClearConfirmation) {
            Button("Yes", role: .destructive) { viewModel.clearForm() }
            Button("No", role: .cancel) { }
        } message: {
            Text("Are you sure you want to clear all form data? This action cannot be undone.")
        }
    }
}

#Preview {
    BuildEntryView()
}
