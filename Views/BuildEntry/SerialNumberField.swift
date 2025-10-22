//
//  SerialNumberField.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/20/25.
//

import SwiftUI

struct SerialNumberField: View {
    let title: String
    @Binding var serialNumber: String
    let onScanTapped: () -> Void
    
    var body: some View {
        HStack {
            TextField(title, text: $serialNumber)
                .autocapitalization(.allCharacters)
            Button(action: onScanTapped) {
                Image(systemName: "camera.fill")
            }
        }
    }
}

#Preview {
    @Previewable @State var serial = ""
    return SerialNumberField(
        title: "Serial Number",
        serialNumber: $serial,
        onScanTapped: { }
    )
    .padding()
}
