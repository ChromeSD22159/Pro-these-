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
            
            SheetHeader("Bearbeite \(contact.name ?? "")", action: {
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
                        Text("Telefon:")
                        
                        Spacer()
                        
                        TextField( text: $eventManager.addContactPhone, prompt: Text("Telefon")) {
                               Text("Telfon:")
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
                            Text(contact.type).tag("\(contact.type)")
                        }
                    }
                }
                .padding(.horizontal, 10)
                .listRowBackground(Color.white.opacity(0.05))
                .foregroundColor(appConfig.fontColor)
                
                Section {
                    HStack {
                        Button("Abbrechen") {}
                            .listRowBackground(Color.white.opacity(0.05))
                        Spacer()
                        Button("Speicher \(contact.name ?? "")") {
                            eventManager.editContact(contact) { success in
                                if success {
                                    eventManager.editContact = nil
                                    eventManager.isAddContactSheet = false
                                }
                            }
                        }.listRowBackground(Color.white.opacity(0.05))
                    }
                    .padding(10)
                    .listRowBackground(Color.white.opacity(0.05))
                }
                .listRowBackground(Color.white.opacity(0.05))
                .foregroundColor(appConfig.fontColor)
                
                
                
                // In-App-ABO
                InfomationField( // In-App-ABO
                    backgroundStyle: .ultraThinMaterial,
                    text: "Die Kontaktdaten beziehen sich auf die Allgemeinen Kontaktinfomationen wie z.B. \"Zentrale\". Sie haben später noch die möglichkeit zusätzliche Ansprechpartner hinzuzufügen.",
                    foreground: .white,
                    visibility: AppConfig.shared.hasUnlockedPro ? appConfig.hideInfomations : true
                )
                .listRowBackground(Color.white.opacity(0))
                .listRowInsets(EdgeInsets())
            }
            
            Spacer()
        }
        .padding(.vertical, 10)
        .scrollContentBackground(.hidden)
        .foregroundColor(.white)
        .onAppear {
            eventManager.addContactName = contact.name ?? ""
            eventManager.addContactPhone = contact.phone ?? ""
            eventManager.addContactEmail = contact.mail ?? ""
            eventManager.addContactTitel = contact.titel ?? ""
        }
    }
    
    @ViewBuilder
    func createContact() -> some View {
        VStack(spacing: 10){
            
            SheetHeader(titel, action: {
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
                        Text("Telefon:")
                        
                        Spacer()
                        
                        TextField( text: $eventManager.addContactPhone, prompt: Text("Telefon")) {
                               Text("Telfon:")
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
                            Text(contact.type).tag("\(contact.type)")
                        }
                    }
                }
                .padding(.horizontal, 10)
                .listRowBackground(Color.white.opacity(0.05))
                .foregroundColor(appConfig.fontColor)
                
                Section {
                    HStack {
                        Button("Abbrechen") {}
                            .listRowBackground(Color.white.opacity(0.05))
                        Spacer()
                        Button("Ertelle Kontakt") {
                            eventManager.addContact()
                        }.listRowBackground(Color.white.opacity(0.05))
                    }
                    .padding(10)
                    .listRowBackground(Color.white.opacity(0.05))
                }
                .listRowBackground(Color.white.opacity(0.05))
                .foregroundColor(appConfig.fontColor)
                
                
                
                // In-App-ABO
                InfomationField( // In-App-ABO
                    backgroundStyle: .ultraThinMaterial,
                    text: "Die Kontaktdaten beziehen sich auf die Allgemeinen Kontaktinfomationen wie z.B. \"Zentrale\". Sie haben später noch die möglichkeit zusätzliche Ansprechpartner hinzuzufügen.",
                    foreground: .white,
                    visibility: AppConfig.shared.hasUnlockedPro ? appConfig.hideInfomations : true
                )
                .listRowBackground(Color.white.opacity(0))
                .listRowInsets(EdgeInsets())
            }
            
            Spacer()
        }
        .padding(.vertical, 10)
        .scrollContentBackground(.hidden)
        .foregroundColor(.white)
    }
}

struct ContentAddSheetBoby_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppConfig.shared.background.ignoresSafeArea()
            
            ContentAddSheetBoby(titel: "Bearbeite <ContactName>")
                .environmentObject(AppConfig())
                .environmentObject(EventManager())
                .environmentObject(ContactManager())
                .colorScheme(.dark)
        }
    }
}
