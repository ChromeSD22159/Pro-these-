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
                /* HASPRO
                if !entitlementManager.hasPro {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(AppConfig.shared.fontColor)
                        .onTapGesture {
                            DispatchQueue.main.async {
                                tabManager.ishasProFeatureSheet.toggle()
                            }
                        }
                }
                 */
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
        
        var nameString = ""
        if name != "" {
            nameString = ", \(name)"
        }
        
        switch hour {
            case 6..<12 : return "Guten Morgen\(nameString)!"
            case 12 : return "Guten Tag\(nameString)!"
            case 13..<17 :  return "Hallo\(nameString)!"
            case 17..<22 : return "Guten Abend\(nameString)!"
            default: return "Hallo\(nameString)!"
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
