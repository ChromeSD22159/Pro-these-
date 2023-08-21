//
//  BackgroundBlurTop.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 12.05.23.
//

import SwiftUI

struct HeaderBackgroundBlurTop: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    var body: some View {
        // MARK: - Background Header blur
        VStack {
            HStack {
                Spacer()
            }
            .frame(height: 50)
            //.background(currentTheme.backgroundHeaderBlur)
            .blur(radius: 5, opaque: false)
            .offset(y: -60)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
