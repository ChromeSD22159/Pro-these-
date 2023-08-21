//
//  InfomationField.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 20.06.23.
//

import SwiftUI

struct InfomationField: View {
    
    var backgroundStyle: Material
    
    var text: LocalizedStringKey?
    
    var foreground: Color?
    
    var lineSpacing: CGFloat?
    
    var visibility: Bool?
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var body: some View {
        
        if visibility ?? true {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.caption.bold())
                    
                    Text("Infomation")
                        .font(.caption.bold())
                    
                    Spacer()
                }
                
                HStack{
                    Text( text ?? LocalizedStringKey(AppConfig.shared.placeholder["info"]!))
                        .lineSpacing(lineSpacing ?? 3)
                        .truncationMode(.head)
                    Spacer()
                }
            }
            .foregroundColor(foreground ?? currentTheme.text)
            .font(.caption2)
            .padding()
            .background(backgroundStyle)
            .cornerRadius(20)
        }
    }
}

struct InfomationField_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            InfomationField(backgroundStyle: Material.ultraThinMaterial, text: "The contact details refer to the general contact information such as \"Headquarters\". You can add additional contacts later.", foreground: .white)
                .environment(\.locale, .init(identifier: "en"))
        }
    }
}
