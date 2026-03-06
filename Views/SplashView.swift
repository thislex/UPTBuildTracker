//
//  SplashView.swift
//  UPTBuildTracker
//
//  Created by Lexter Tapawan on 10/7/25.
//

import SwiftUI

struct SplashView: View {
    let onFinish: () -> Void

    var body: some View {
        GeometryReader { geo in
            Image("LaunchImage")
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            onFinish()
        }
    }
}
