//
//  PINTextField.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/20/25.
//

import SwiftUI

struct PINTextField: View {
    let title: String
    @Binding var pin: String
    
    var body: some View {
        TextField(title, text: $pin)
            .keyboardType(.numberPad)
            .onChange(of: pin) { oldValue, newValue in
                // Keep only numeric characters and limit to 6 digits
                let filtered = newValue.filter { $0.isNumber }
                if filtered.count > 6 {
                    pin = String(filtered.prefix(6))
                } else if filtered != newValue {
                    pin = filtered
                }
            }
            .overlay(alignment: .trailing) {
                if !pin.isEmpty {
                    Image(systemName: pin.count == 6 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .foregroundStyle(pin.count == 6 ? .green : .orange)
                        .padding(.trailing, 8)
                }
            }
    }
}

#Preview {
    @Previewable @State var pin = "123456"
    return PINTextField(title: "PIN Code", pin: $pin)
        .padding()
}
