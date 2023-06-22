//
//  HeaderComponent.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 27.04.23.
//

import SwiftUI

struct HeaderComponent: View {
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var entitlementManager: EntitlementManager
    var body: some View {
        HStack(){
            VStack(spacing: 2) {
                Text(sayHallo(name: appConfig.username) )
                    .font(.title2)
                    .foregroundColor(appConfig.fontColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Dein Tagesziel ist für heute \(appConfig.targetSteps) Schritte")
                    .font(.callout)
                    .foregroundColor(appConfig.fontLight)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack(spacing: 20){
                
                if !entitlementManager.hasPro {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(AppConfig.shared.fontColor)
                        .onTapGesture {
                            DispatchQueue.main.async {
                                tabManager.ishasProFeatureSheet.toggle()
                            }
                        }
                }
                
                Image(systemName: "gearshape")
                    .foregroundColor(appConfig.fontColor)
                    .onTapGesture {
                        tabManager.isSettingSheet.toggle()
                    }
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
    }
    
    func sayHallo(name: String) -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        let string = ""
        
        switch hour {
            case 6..<12 : return "Guten Morgen, \(name)!"
            case 12 : return "Guten Tag, \(name)!"
            case 13..<17 :  return "Hallo \(name)!"
            case 17..<22 : return "Guten Abend, \(name)!"
            default: return "Hallo, \(name)!"
        }

    }
}

struct HeaderComponent_Previews: PreviewProvider {
    static var previews: some View {
        HeaderComponent()
            .environmentObject(AppConfig())
            .environmentObject(TabManager())
            .environmentObject(EntitlementManager())
    }
}
