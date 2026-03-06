//
//  CBMiniContentView.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//

import SwiftUI

struct CBMiniContentView: View {
    let onGoHome: () -> Void
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            CBMiniBuildEntryView(onGoHome: onGoHome)
                .tabItem {
                    Label("New Build", systemImage: "plus.circle.fill")
                }
                .tag(0)

            CBMiniArchiveView()
                .tabItem {
                    Label("Pending", systemImage: "clock.arrow.circlepath")
                }
                .tag(1)

            SettingsView(onGoHome: onGoHome)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
    }
}
