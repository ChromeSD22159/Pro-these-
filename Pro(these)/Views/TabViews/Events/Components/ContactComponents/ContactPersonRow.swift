//
//  ContactPersonRow.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 08.05.23.
//

import SwiftUI
struct ContactPersonRow: View {
    var person: ContactPerson
    var focusedTask: FocusState<ContactPerson?>.Binding
    @EnvironmentObject var eventManager: EventManager
    @StateObject var contactManager = ContactManager()
    @State var toggleState: Bool = false
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    var body: some View {
        HStack {
            
            Text(person.title ?? "Titel")
            
            TextField(person.firstname ?? "Max", text: Binding(get: {person.firstname ?? ""}, set: {person.firstname = $0}), onEditingChanged: { _ in
                do {
                    try PersistenceController.shared.container.viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            })
            .font(.body)
            
            TextField(person.lastname ?? "Musterman", text: Binding(get: {person.lastname ?? ""}, set: { person.lastname = $0 }), onEditingChanged: { _ in
                do {
                    try PersistenceController.shared.container.viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            })
            .font(.body)
            
            HStack(spacing: 15) {
                Button(action: {
                    let dash = CharacterSet(charactersIn: "-")
                    let cleanString = person.phone?.trimmingCharacters(in: dash)
                    let tel = "tel://"
                    let formattedString = tel + (cleanString ?? "0")
                    let url: NSURL = URL(string: formattedString)! as NSURL

                    UIApplication.shared.open(url as URL)
                }, label: {
                    Image(systemName: "phone")
                        .font(.title3)
                        .foregroundColor(person.phone?.count ?? 0 < 1 ? currentTheme.textGray : currentTheme.text)
                })
                .interactiveDismissDisabled(!contactManager.armed)
                .foregroundColor(((person.phone?.count ?? 0) > 1) ?  currentTheme.textGray : currentTheme.text)
                .disabled(person.phone?.count ?? 0 < 1)
                
                Button(action: {
                    let dash = CharacterSet(charactersIn: "-")
                    let cleanString = person.mobil?.trimmingCharacters(in: dash)
                    let tel = "tel://"
                    let formattedString = tel + (cleanString ?? "0")
                    let url: NSURL = URL(string: formattedString)! as NSURL

                    UIApplication.shared.open(url as URL)
                }, label: {
                    Image(systemName: "platter.filled.bottom.iphone")
                        .font(.title3)
                        .foregroundColor(person.mobil?.count ?? 0 < 1 ? currentTheme.textGray : currentTheme.text)
                })
                .interactiveDismissDisabled(!contactManager.armed)
                .foregroundColor(((person.mobil?.count ?? 0) > 1) ?  currentTheme.textGray : currentTheme.text)
                .disabled(person.mobil?.count ?? 0 < 1)

                
                Button(action: {
                    EmailController.shared.sendEmail(subject: "Inquiry", body: "Erstellt aus der \"Pro Prothesen App.\"", to: person.mail ?? "")
                 }) {
                     Image(systemName: "envelope")
                         .font(.title3)
                         .foregroundColor(person.mail?.count ?? 0 < 10 ? currentTheme.textGray : currentTheme.text)
                 }
                .foregroundColor(currentTheme.text)
                .disabled(person.mail?.count ?? 0 < 10)
                
                
                Confirm(message: "Delete '\( person.firstname ?? "" ) \( person.lastname ?? "" )'?", buttonText: "", buttonIcon: "trash", content: {
                    Button("Delete") { eventManager.deleteContactPerson(person) }
                })
                .font(.title3)
            }
        }
        .foregroundColor(currentTheme.text )
        .padding(5)
    }
}

// 0765074505
// 077514231
