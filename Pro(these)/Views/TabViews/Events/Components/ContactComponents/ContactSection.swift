//
//  ContactSection.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 04.05.23.
//

import SwiftUI

struct ContactSection: View {
    @EnvironmentObject var eventManager: EventManager
    
    @EnvironmentObject var appConfig: AppConfig
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var titel: String
    
    var body: some View {
        Section(content: {
            if !eventManager.contacts.isEmpty {
                ForEach(eventManager.contacts){ contact in
                    NavigateTo({
                        ContactPreview(icon: contact.icon ?? "", color: currentTheme.hightlightColor, name: contact.name ?? "Unknown Name" , titel: contact.titel ?? "Unknown Titel")
                    }, {
                        ContactDetailView(contact: contact, iconColor: currentTheme.hightlightColor)
                    })
                }
            } else {
                HStack(alignment: .center){
                    Spacer()
                    Text("No contact available!")
                        .font(.caption2)
                    Spacer()
                }
            }
        }, header: {
            HStack{
                Text(titel)
                    .font(.caption2)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button(action: { eventManager.isAddContactSheet.toggle() }, label: {
                    Label("Add Contact", systemImage: "plus")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.trailing, 20)
                })
            }
            
        })
        .tint(currentTheme.text)
        .listRowBackground(currentTheme.text.opacity(0.05))
    }
}

