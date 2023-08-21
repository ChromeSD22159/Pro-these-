//
//  SettingToggleButton.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 27.04.23.
//

import SwiftUI

struct SettingToggleButton: View {
    var image: String
    var toggleDescrition:LocalizedStringKey
    var info: LocalizedStringKey
    var inVisible: Bool?
    var proFeature: Bool?
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @Binding var storeBinding: Bool
    
    var body: some View {
        HStack(){
            // Image
            VStack(){
                Image(systemName: image)
                    .frame(width: 20, height: 20)
                    .foregroundColor(currentTheme.text)
            }
            .padding(6)
            .background(currentTheme.primary)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(currentTheme.text, lineWidth: 1)
            )
            .frame(maxWidth: 50)
            
            Spacer(minLength: 20)
            
            VStack(alignment: .leading, spacing: 5){
                HStack{
                    Text(toggleDescrition)
                        .font(.caption.bold())
                        .foregroundColor(currentTheme.text)
                        .padding(.bottom, 1)
                    
                    if let pro = proFeature {
                        if !AppConfig.shared.hasPro && pro == true {
                            Text("PRO")
                                .font(.caption2.bold())
                                .foregroundColor(currentTheme.hightlightColor)
                                .padding(5)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(currentTheme.primary)
                                        
                                )
                                .padding(.bottom, 1)
                        }
                    }
                    
                    Spacer()
                }

                HStack{
                    Text(info)
                        .font(.caption2)
                        .lineSpacing(3)
                        .foregroundColor(currentTheme.text.opacity(0.8))
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            
            Spacer(minLength: 10)
            
            VStack{
                Toggle("", isOn: $storeBinding)
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                    .disabled(inVisible != nil ? true : false)
            }
            .frame(maxWidth: 50)
            
        }
        .padding(12)
        .background(currentTheme.primary.opacity(0.5))
        .cornerRadius(10)
    }
}

struct SettingToggleButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Theme.blue.gradientBackground(nil).ignoresSafeArea()
            
            SettingToggleButton(image: "info", toggleDescrition: "Zeige erfüllte Tagesziele an", info: "Zeigt den Record Button auch auf der Schrittüberischt an.", storeBinding: .constant(false))
        }
    }
}
