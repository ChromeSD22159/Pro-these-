//
//  BackBTN.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 27.04.23.
//

import SwiftUI

struct BackBTN: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    var size: CGFloat
    var foreground: Color?
    var background: Color?
    
    var body: some View {
        ZStack{
            ZStack {
                Image(systemName: "chevron.left.circle")
                    .foregroundColor(foreground ?? currentTheme.text)
                    .font(.system(size: size))
                
            }.background(
                GlassBackGround(width: size, height: size, color: background ?? currentTheme.textBlack)
                    .shadow(color: currentTheme.textBlack, radius: size, x: 2, y: 2)
            )
            
            
        }
    }
}
