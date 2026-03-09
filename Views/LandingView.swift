//
//  LandingView.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//

import SwiftUI
import MessageUI

enum ProductSelection {
    case upt, cbMini
}

struct LandingView: View {
    let onSelect: (ProductSelection) -> Void
    @State private var appeared = false
    @State private var showingBugReport = false

    var body: some View {
        ZStack {
            // Subtle gradient background
            LinearGradient(
                colors: [
                    Color(UIColor.systemBackground),
                    Color(UIColor.secondarySystemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // App-icon style header
                VStack(spacing: 16) {
                    Image("LaunchImage")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 110, height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                        .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 12)
                        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)

                    VStack(spacing: 6) {
                        Text("CFD Builds")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .foregroundStyle(.primary)

                        Text("Select a product to get started")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.9)
                .animation(.spring(response: 0.5, dampingFraction: 0.75), value: appeared)

                Spacer().frame(height: 48)

                // Product cards
                VStack(spacing: 14) {
                    ProductCard(
                        title: "SCOUT UPT",
                        subtitle: "Track UPT build components and sync to Google Sheets",
                        systemImage: "wrench.and.screwdriver.fill",
                        color: Color(red: 0.2, green: 0.5, blue: 1.0)
                    ) {
                        onSelect(.upt)
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.15), value: appeared)

                    ProductCard(
                        title: "Crooked Box Mini",
                        subtitle: "Build entry for Crooked Box Mini units",
                        systemImage: "shippingbox.fill",
                        color: Color(red: 1.0, green: 0.58, blue: 0.0)
                    ) {
                        onSelect(.cbMini)
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.25), value: appeared)
                }
                .padding(.horizontal, 20)

                Spacer()
                Spacer()

                VStack(spacing: 8) {
                    Text("CFD Build Tracker™ 2026")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)

                    Button {
                        showingBugReport = true
                    } label: {
                        Label("Report a Bug", systemImage: "ladybug")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 20)
                .opacity(appeared ? 1 : 0)
            }
        }
        .sheet(isPresented: $showingBugReport) {
            BugReportView()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.45)) {
                appeared = true
            }
        }
    }
}

private struct ProductCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let color: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color.gradient)
                        .frame(width: 60, height: 60)
                        .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)

                    Image(systemName: systemImage)
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(.body, design: .rounded, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(isPressed ? 0.02 : 0.07), radius: isPressed ? 2 : 10, x: 0, y: isPressed ? 1 : 5)
            }
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Bug Report View

private struct BugReportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var showingComposer = false
    @State private var showMailUnavailableAlert = false

    private let recipientEmail = "lexter.tapawan@pm.me"

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("What went wrong?")) {
                    TextField("Short summary", text: $title)
                }
                Section(header: Text("Description")) {
                    TextEditor(text: $description)
                        .frame(minHeight: 120)
                }
                Section {
                    Button(action: submitReport) {
                        Label("Send Bug Report", systemImage: "paperplane.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("Report a Bug")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showingComposer) {
                MailComposerView(
                    recipient: recipientEmail,
                    subject: "[Bug] \(title)",
                    body: description
                ) {
                    dismiss()
                }
            }
            .alert("Mail Unavailable", isPresented: $showMailUnavailableAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("No Mail account is set up on this device. Please email \(recipientEmail) directly.")
            }
        }
    }

    private func submitReport() {
        if MFMailComposeViewController.canSendMail() {
            showingComposer = true
        } else {
            showMailUnavailableAlert = true
        }
    }
}

// MARK: - Mail Composer UIViewControllerRepresentable

private struct MailComposerView: UIViewControllerRepresentable {
    let recipient: String
    let subject: String
    let body: String
    let onDismiss: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onDismiss: onDismiss) }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients([recipient])
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onDismiss: () -> Void
        init(onDismiss: @escaping () -> Void) { self.onDismiss = onDismiss }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            controller.dismiss(animated: true)
            if result == .sent { onDismiss() }
        }
    }
}

#Preview {
    LandingView { selection in
        print("Selected: \(selection)")
    }
}
