//
//  CBMiniBuildEntryView.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//

import SwiftUI

struct CBMiniBuildEntryView: View {
    var onGoHome: (() -> Void)? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.orange)

                VStack(spacing: 8) {
                    Text("Coming Soon")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Crooked Box Mini build entry\nform is under development.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("CB Mini Build Entry")
            .toolbar {
                if let goHome = onGoHome {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            goHome()
                        } label: {
                            Label("Home", systemImage: "house.fill")
                        }
                    }
                }
            }
        }
    }
}
