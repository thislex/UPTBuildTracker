//
//  CBMiniArchiveView.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//

import SwiftUI

struct CBMiniArchiveView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "archivebox")
                    .font(.system(size: 64))
                    .foregroundStyle(.secondary)

                VStack(spacing: 8) {
                    Text("No Builds Yet")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Completed CB Mini builds will\nappear here once the build entry\nform is available.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("CB Mini Archive")
        }
    }
}
