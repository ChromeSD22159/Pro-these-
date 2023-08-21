//
//  ContentAddSheetBoby.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 04.05.23.
//

import SwiftUI

struct ContentAddSheetBoby: View {
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var contactManager: ContactManager
    @EnvironmentObject var ads: AdsViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var titel: String
    var body: some View {
        ZStack{
            if let contact = eventManager.editContact {
                editContact(contact)
            } else {
                createContact()
            }
        }
        .fullSizeTop()
    }
    @ViewBuilder
    func editContact(_ contact: Contact) -> some View {
        VStack(spacing: 10){
            
            SheetHeader(title: "Edit", action: {
                eventManager.isAddContactSheet.toggle()
                
                // Show InterstitialSheet if not Pro
                if !appConfig.hasPro {
                   ads.showInterstitial.toggle()
                }
            })
            
            Form {
                Section {
                    HStack{
                        Text("Name:")
                        
                        TextField( text: $eventManager.addContactName, prompt: Text("Name")) {
                               Text("Name")
                           }
                        .disableAutocorrection(true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                    HStack{
                        Text("Phone:")
                        
                        Spacer()
                        
                        TextField( text: $eventManager.addContactPhone, prompt: Text("Phone")) {
                               Text("Phone:")
                           }
                        .disableAutocorrection(true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack{
                        Text("E-Mail:")
                        
                        Spacer()
                        
                        TextField( text: $eventManager.addContactEmail, prompt: Text("E-Mail:")) {
                            Text("E-Mail:")
                        }
                        .disableAutocorrection(true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Picker("Titel", selection: $eventManager.addContactTitel) {
                        ForEach(eventManager.contactTypes, id: \.type) { contact in
                            Text(contact.name).tag("\(contact.type)")
                        }
                    }
                }
                .padding(.horizontal, 10)
                .listRowBackground(currentTheme.text.opacity(0.05))
                .foregroundColor(currentTheme.text)
                
                Section {
                    HStack {
                        Button("Cancel") {
                            // Show InterstitialSheet if not Pro
                            if !appConfig.hasPro {
                               ads.showInterstitial.toggle()
                            }
                        }
                            .listRowBackground(currentTheme.text.opacity(0.05))
                        Spacer()
                        Button("Save") {
                            eventManager.editContact(contact) { success in
                                if success {
                                    eventManager.editContact = nil
                                    eventManager.isAddContactSheet = false
                                }
                            }
                            
                            // Show InterstitialSheet if not Pro
                            if !appConfig.hasPro {
                               ads.showInterstitial.toggle()
                            }
                        }.listRowBackground(currentTheme.text.opacity(0.05))
                    }
                    .padding(10)
                    .listRowBackground(currentTheme.text.opacity(0.05))
                }
                .listRowBackground(currentTheme.text.opacity(0.05))
                .foregroundColor(currentTheme.text)
                
                
                
                // In-App-ABO
                InfomationField( // In-App-ABO
                    backgroundStyle: .ultraThinMaterial,
                    text: "The contact details refer to the general contact information such as \"Headquarters\". You can add additional contacts later.",
                    foreground: currentTheme.text,
                    visibility: AppConfig.shared.hasUnlockedPro ? appConfig.hideInfomations : true
                )
                .listRowBackground(currentTheme.text.opacity(0))
                .listRowInsets(EdgeInsets())
            }
            
            Spacer()
        }
        .padding(.vertical, 10)
        .scrollContentBackground(.hidden)
        .foregroundColor(currentTheme.text)
        .onAppear {
            eventManager.addContactName = contact.name ?? ""
            eventManager.addContactPhone = contact.phone ?? ""
            eventManager.addContactEmail = contact.mail ?? ""
            eventManager.addContactTitel = contact.titel ?? "Others"
            eventManager.addEventIcon = contact.icon ?? ""
        }
    }
    
    @ViewBuilder
    func createContact() -> some View {
        VStack(spacing: 10){
            
            SheetHeader(title: "New Contact", action: {
                eventManager.isAddContactSheet.toggle()
            })
            
            Form {
                Section {
                    HStack{
                        Text("Name:")
                        
                        TextField( text: $eventManager.addContactName, prompt: Text("Name")) {
                               Text("Name")
                           }
                        .disableAutocorrection(true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                    HStack{
                        Text("Phone:")
                        
                        Spacer()
                        
                        TextField( text: $eventManager.addContactPhone, prompt: Text("Phone")) {
                               Text("Phone:")
                           }
                        .disableAutocorrection(true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack{
                        Text("E-Mail:")
                        
                        Spacer()
                        
                        TextField( text: $eventManager.addContactEmail, prompt: Text("E-Mail:")) {
                            Text("E-Mail:")
                        }
                        .disableAutocorrection(true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Picker("Titel", selection: $eventManager.addContactTitel) {
                        ForEach(eventManager.contactTypes, id: \.type) { contact in
                            Text(contact.name).tag("\(contact.type)")
                        }
                    }
                }
                .padding(.horizontal, 10)
                .listRowBackground(currentTheme.text.opacity(0.05))
                .foregroundColor(currentTheme.text)
                
                Section {
                    HStack {
                        Button("Cancel") {
                            // Show InterstitialSheet if not Pro
                            if !appConfig.hasPro {
                               ads.showInterstitial.toggle()
                            }
                        }
                            .listRowBackground(currentTheme.text.opacity(0.05))
                        Spacer()
                        Button("Save") {
                            eventManager.addContact()
                            
                            // Show InterstitialSheet if not Pro
                            if !appConfig.hasPro {
                               ads.showInterstitial.toggle()
                            }
                        }.listRowBackground(currentTheme.text.opacity(0.05))
                    }
                    .padding(10)
                    .listRowBackground(currentTheme.text.opacity(0.05))
                }
                .listRowBackground(currentTheme.text.opacity(0.05))
                .foregroundColor(currentTheme.text)
                
                
                
                // In-App-ABO
                InfomationField( // In-App-ABO
                    backgroundStyle: .ultraThinMaterial,
                    text: "The contact details refer to the general contact information such as \"Headquarters\". You can add additional contacts later.",
                    foreground: currentTheme.text,
                    visibility: AppConfig.shared.hasUnlockedPro ? appConfig.hideInfomations : true
                )
                .listRowBackground(currentTheme.text.opacity(0))
                .listRowInsets(EdgeInsets())
            }
            
            Spacer()
        }
        .padding(.vertical, 10)
        .scrollContentBackground(.hidden)
        .foregroundColor(currentTheme.text)
    }
}

struct ContentAddSheetBoby_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Theme.blue.gradientBackground(nil).ignoresSafeArea()
            
            ContentAddSheetBoby(titel: "Edit <ContactName>")
                .environmentObject(AppConfig())
                .environmentObject(EventManager())
                .environmentObject(ContactManager())
                .colorScheme(.dark)
        }
    }
}
