//
//  Theme.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 25.07.23.
//

import SwiftUI
import Foundation

///
/// 1. PersonalDeteilsView -> add <Color> to the Array for the Switcher
/// 2. func currentTheme apply the color in the switch state
/// 3. change the Colors


class ThemeManager: ObservableObject {
    @Published var current: Theme = Theme.blue
    
    func currentTheme() -> Theme {
        @AppStorage("currentTheme", store: AppConfig.store) var currentTheme: String = "blue"
        
        switch currentTheme {
            case "blue" : return .blue
            case "green" : return .green
            case "orange" : return .orange
            default:
                return .blue
        }
    }

    func applyTheme(theme: Theme) {
        @AppStorage("currentTheme", store: AppConfig.store) var currentTheme: String = theme.rawValue
    }
}

enum Theme: String, CaseIterable {    

    case blue = "blue"
    case green = "green"
    case orange = "orange"
    
    var name: String {
        switch self {
            case .blue: return "blue"
            case .green: return "green"
            case .orange: return "orange"
        }
    }

    enum background {
        case gradient, label, radial
    }
    
    func background(_ type: Theme.background) -> Gradient { //(color: Color, gradient: LinearGradient, label: LinearGradient, radial: RadialGradient)
        
        switch type {
            case .gradient:
                switch self {
                    case .blue: return Gradient(colors: [Color(red: 32/255, green: 40/255, blue: 63/255), Color(red: 4/255, green: 5/255, blue: 8/255)])
                    case .green: return  Gradient(colors: [Color(red: 32/255, green: 32/255, blue: 32/255), Color(red: 0/255, green: 0/255, blue: 0/255)])
                    case .orange: return  Gradient(colors: [Color(red: 16/255, green: 16/255, blue: 16/255), Color(red: 0/255, green: 0/255, blue: 0/255)])
                }
                
            case .label:
                switch self {
                    case .blue: return Gradient(colors: [Color(red: 32/255, green: 40/255, blue: 63/255)])
                    case .green: return Gradient(colors: [Color(red: 32/255, green: 32/255, blue: 32/255)])
                    case .orange: return Gradient(colors: [Color(red: 16/255, green: 16/255, blue: 16/255)])
                }
                
            case .radial:
                switch self {
                    case .blue: return Gradient(colors:[ Color(red: 5/255, green: 5/255, blue: 15/255).opacity(0.7), Color(red: 5/255, green: 5/255, blue: 15/255).opacity(1) ])
                    case .green: return Gradient(colors:[ Color(red: 32/255, green: 32/255, blue: 32/255).opacity(0.7), Color(red: 32/255, green: 32/255, blue: 32/255).opacity(1) ])
                    case .orange: return Gradient(colors:[ Color(red: 16/255, green: 16/255, blue: 16/255).opacity(0.7), Color(red: 16/255, green: 16/255, blue: 16/255).opacity(1) ])
                }
            
        }
    }
    
    /// AppConfig.shared.background  == backgroundColor
    var backgroundColor: Color {
        switch self {
            case .blue: return Color(red: 32/255, green: 40/255, blue: 63/255)
            case .green: return Color(red: 32/255, green: 32/255, blue: 32/255)
            case .orange: return Color(red: 16/255, green: 16/255, blue: 16/255) // 101010
        }
    }
    
    var backgroundColorDark: Color {
        switch self {
            case .blue: return Color(red: 4/255, green: 5/255, blue: 8/255)
            case .green: return Color(red: 4/255, green: 5/255, blue: 8/255)
            case .orange: return Color(red: 4/255, green: 5/255, blue: 8/255)
        }
    }
    
    var mapOverlayBackground: RadialGradient {
        switch self {
            case .blue: return RadialGradient(gradient: Gradient(colors: [
                Color(red: 5/255, green: 5/255, blue: 15/255).opacity(0.35),
                Color(red: 5/255, green: 5/255, blue: 15/255) //Color(red: 32/255, green: 40/255, blue: 63/255).opacity(1)
            ]), center: .center, startRadius: 50, endRadius: 300)
            
            case .green: return RadialGradient(gradient: Gradient(colors: [
                Color(red: 5/255, green: 5/255, blue: 15/255).opacity(0.35),
                Color(red: 32/255, green: 32/255, blue: 32/255)
            ]), center: .center, startRadius: 50, endRadius: 300)
            
            case .orange: return RadialGradient(gradient: Gradient(colors: [
                Color(red: 40/255, green: 10/255, blue: 10/255).opacity(0.35), // 280D0B
                Color(red: 16/255, green: 16/255, blue: 16/255) // 101010
            ]), center: .center, startRadius: 50, endRadius: 300)
        }
    }
    
    var backgroundHeaderBlur: Color {
        switch self {
            case .blue: return Color(red: 5/255, green: 5/255, blue: 15/255)
            case .green: return Color(red: 32/255, green: 32/255, blue: 32/255)
            case .orange: return Color(red: 32/255, green: 32/255, blue: 32/255)
        }
    }
    
    var LaunchScreenImage: String {
        switch self {
            case .blue: return "LaunchImage"
            case .green: return "LaunchImage"
            case .orange: return "LaunchImage"
        }
    }
    
    func labelBackground(_ unitPoint: [UnitPoint]?) -> LinearGradient {
        return LinearGradient(gradient: self.background(.label), startPoint: unitPoint?.first ?? .top, endPoint: unitPoint?.last ?? .bottom)
    }
    
    func gradientBackground(_ unitPoint: [UnitPoint]?) -> LinearGradient {
        return LinearGradient(gradient: self.background(.gradient), startPoint: unitPoint?.first ?? .top, endPoint: unitPoint?.last ?? .bottom)
    }
    
    func radialBackground(unitPoint: UnitPoint?,radius: [CGFloat]?) -> RadialGradient {
        return RadialGradient(gradient: self.background(.radial), center: .center, startRadius: radius?.first ?? 50, endRadius: radius?.last ?? 300)
    }
    
    var gaugeGradient: LinearGradient {
        return LinearGradient(colors: [self.primary], startPoint: .top, endPoint: .bottom)
    }
    
    var primary: Color { // gesättigt
        switch self {
            case .blue: return Color(red: 32/255, green: 40/255, blue: 63/255)
            case .green: return Color(red: 32/255, green: 32/255, blue: 32/255)
            case .orange: return Color(red: 52/255, green: 52/255, blue: 52/255)
        }
    }

    var secondary: Color { // light
        switch self {
            case .blue: return Color(red: 255/255, green: 245/255, blue: 140/255)
            case .green: return Color(red: 200/255, green: 255/255, blue: 200/255)
            case .orange: return Color(red: 255/255, green: 130/255, blue: 80/255) //
        }
    }
    
    var hightlightColor: Color {
        switch self {
            case .blue: return Color(red: 248/255, green: 224/255, blue: 0/255)
            case .green: return Color(red: 86/255, green: 178/255, blue: 118/255)
            case .orange: return Color(red: 255/255, green: 85/255, blue: 0/255) // FF5500
        }
    }

    var accentColor: Color {
        switch self {
            case .blue: return Color(red: 167/255, green: 178/255, blue: 210/255)
            case .green: return Color(red: 200/255, green: 255/255, blue: 200/255)
            case .orange: return  Color(red: 255/255, green: 130/255, blue: 80/255) // FF8250
        }
    }
    
    var text: Color { // gesättigt
        return Color(.white)
    }
    
    var textGray: Color { // gesättigt
        return Color(.gray)
    }
    
    var textBlack: Color { // gesättigt
        return Color(.black)
    }
    
    enum textStyle {
        case dark, light, `default`
    }
    
    func text(_ type: Theme.textStyle?) -> Color { //(color: Color, gradient: LinearGradient, label: LinearGradient, radial: RadialGradient)
        
        switch type {
            case .dark:
                switch self {
                    case .blue: return .primary
                    case .green: return .primary
                    case .orange: return .primary
                }
                
            case .light:
                switch self {
                    case .blue: return self.secondary
                    case .green: return self.secondary
                    case .orange: return self.secondary
                }
                
            case .default:
                switch self {
                    case .blue: return .white
                    case .green: return .white
                    case .orange: return .white
                }
            
        case .none:
            switch self {
                case .blue: return .white
                case .green: return .white
                case .orange: return .white
            }
        }
    }
}
