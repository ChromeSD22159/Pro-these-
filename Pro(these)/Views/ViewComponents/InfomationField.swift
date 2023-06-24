//
//  InfomationField.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 20.06.23.
//

import SwiftUI

struct InfomationField: View {
    
    var backgroundStyle: Material
    
    var text: String?
    
    var foreground: Color?
    
    var lineSpacing: CGFloat?
    
    var visibility: Bool?
    
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
                    Text((text ?? AppConfig.shared.placeholder["info"]) ?? "")
                        .lineSpacing(lineSpacing ?? 3)
                        .truncationMode(.head)
                    Spacer()
                }
            }
            .foregroundColor(foreground ?? .white)
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
            
            InfomationField(backgroundStyle: Material.ultraThinMaterial, text: "Die Kontaktdaten beziehen sich auf die Allgemeinen Kontaktinfomationen wie z.B. \"Zentrale\". Sie haben später noch die möglichkeit zusätzliche Ansprechpartner hinzuzufügen.", foreground: .white)
                .environment(\.locale, .init(identifier: "en"))
        }
    }
}
