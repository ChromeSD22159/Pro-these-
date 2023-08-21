//
//  hasProFeater.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 20.06.23.
//

import SwiftUI


extension View {
    func hasProBlurry(_ state: Bool) -> some View {
        modifier(hasProFeatureModifier(state: state))
    }
}

struct hasProFeatureModifier: ViewModifier {
    
    var state: Bool
    
    func body(content: Content) -> some View {
        content
            .blur(radius: state ? 2 : 0)
    }
}

///hasProFeatureOverlay(binding: AppConfig.shared.hasUnlockedPro) { state in
///ViewThatFits { .. }
///    .hasProBlurry(state)
///}
struct hasProFeatureOverlay<Content:View>: View {
    
    var content: (Bool) -> Content
    
    var binding: Bool
    
    var label: Bool?
    
    init(binding: Bool, label: Bool? = false, content: @escaping(Bool) -> Content){
        self.binding = binding
        self.content = content
        self.label = label
    }
    
    var body: some View {
        ZStack {
            content(binding)
            
            if binding { // AppConfig.shared.hasUnlockedPro
                ZStack {
                    if (label ?? false) {
                        Image("ProLabel")
                            .resizable()
                            .frame(width: 75, height: 75)
                    } else {
                        Text("Pro Feature")
                            .font(.caption2.bold())
                    }
                }
                .cornerRadius(10)
            }
        }
    }
}
