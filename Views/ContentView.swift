//
//  ContentView.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//

import SwiftUI

// MARK: - App State

enum AppState {
    case splash, landing, upt, cbMini
}

// MARK: - Root View

struct RootView: View {
    @State private var appState: AppState = .splash

    var body: some View {
        ZStack {
            switch appState {
            case .splash:
                SplashView {
                    withAnimation(.easeInOut(duration: 0.5)) { appState = .landing }
                }
                .transition(.opacity)

            case .landing:
                LandingView { selection in
                    withAnimation(.easeInOut(duration: 0.5)) {
                        appState = selection == .upt ? .upt : .cbMini
                    }
                }
                .transition(.opacity)

            case .upt:
                UPTContentView {
                    withAnimation(.easeInOut(duration: 0.5)) { appState = .landing }
                }
                .transition(.opacity)

            case .cbMini:
                CBMiniContentView {
                    withAnimation(.easeInOut(duration: 0.5)) { appState = .landing }
                }
                .transition(.opacity)
            }
        }
    }
}

// MARK: - UPT Content View

struct UPTContentView: View {
    let onGoHome: () -> Void
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            BuildEntryView(onGoHome: onGoHome)
                .tabItem {
                    Label("New Build", systemImage: "plus.circle.fill")
                }
                .tag(0)

            ArchiveView()
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
