//
//  DetailRow.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//


import SwiftUI

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}