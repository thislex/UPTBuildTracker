//
//  SerialNumberField.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/20/25.
//

import SwiftUI

struct SerialNumberField<T: Hashable>: View {
    let title: String
    @Binding var serialNumber: String
    let onScanTapped: () -> Void
    var focused: FocusState<T?>.Binding? = nil
    var focusValue: T? = nil
    
    var body: some View {
        HStack {
            Group {
                if let focused = focused, let focusValue = focusValue {
                    TextField(title, text: $serialNumber)
                        .focused(focused, equals: focusValue)
                } else {
                    TextField(title, text: $serialNumber)
                }
            }
            .autocapitalization(.allCharacters)
            
            Button(action: onScanTapped) {
                Image(systemName: "camera.fill")
            }
        }
    }
}

#Preview {
    @Previewable @State var serial = ""
    SerialNumberField<Int>(
        title: "Serial Number",
        serialNumber: $serial,
        onScanTapped: { }
    )
    .padding()
}
