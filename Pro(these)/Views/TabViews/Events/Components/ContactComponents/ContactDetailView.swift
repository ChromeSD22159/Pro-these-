//
//  ContactDetailView.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 04.05.23.
//

import Foundation
import SwiftUI
import EventKit

struct ContactDetailView: View {
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var eventManager: EventManager
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var pushNotificationManager: PushNotificationManager
    @StateObject var contactManager = ContactManager()
    @State var SelectedContact: Contact?
    @FocusState private var focusedContactPerson: ContactPerson?
    
    var contact: Contact
    var iconColor: Color
    var body: some View {
        ZStack {
            appConfig.backgroundGradient
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack{
                    // MARK: - Page Header
                    HStack{
                        Spacer()
                        
                        Text(contact.name ?? "Unbekannter Name")
                            .foregroundColor(appConfig.fontColor)
                        
                        Spacer()
                        
                        Button(action: {
                            eventManager.editContact = contact
                            eventManager.isAddContactSheet.toggle()
                        }, label: {
                            Image(systemName: "pencil")
                                .foregroundColor(.white)
                                .font(.title3)
                        })
                        
                    }
                    .padding(.top, 25)
                    
                    // MARK: - Foreach ContactPerson
                    VStack{
                        HStack(spacing: 10){
                            Text("Ansprachspartner")
                                .font(.callout)
                            
                            Spacer()
                            
                            Button {
                                contactManager.isShowAddContactPersonSheet.toggle()
                                SelectedContact = contact
                            } label: {
                                HStack {
                                    Image(systemName: "person.badge.plus")
                                        .font(.body)
                                }
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        
                        if (contact.contactPersons?.allObjects as? [ContactPerson] ?? []).count == 0 {
                            HStack(spacing: 10){
                                Text("Kein Ansprechpartner vorhanden.")
                                Spacer()
                            }
                            .padding(20)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(20)
                        } else {
                            ForEach(contact.contactPersons?.allObjects as? [ContactPerson] ?? [] , id: \.self) { person in //
                                
                                HStack(spacing: 10){
                                    Image(systemName: "person")
                                        .font(.body)
                                        .padding(.trailing)
                                    
                                    ContactPersonRow(person: person, focusedTask: $focusedContactPerson)
                                }
                                .padding(20)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(20)
                            }
                        }
                       
                    }
                    .padding(.top, 50)
                    
                    // MARK: - Foreach Recurring Events
                    VStack{
                        VStack{
                            HStack(spacing: 20){
                                Text("Wiederholende Benachrichtigungen")
                                    .font(.callout)
                                Spacer()
                                
                                Button {
                                    contactManager.isShowAddContactRhymusSheet.toggle()
                                    SelectedContact = contact
                                } label: {
                                    HStack {
                                        Image(systemName: "goforward.plus")
                                            .font(.body)
                                    }
                                }
                                .foregroundColor(appConfig.fontColor)
                                
                                if AppConfig().debug {
                                    Button {
                                        pushNotificationManager.removeAllPendingNotificationRequests()
                                    } label: {
                                        Image(systemName: "bell.slash.circle")
                                            .font(.body)
                                    }
                                }
                            }
                          
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            
                            if (contact.recurringEvents?.allObjects as? [RecurringEvents] ?? []).count == 0 {
                                HStack(spacing: 10){
                                    Text("Keine Benachrichtigungen vorhanden.")
                                    Spacer()
                                }
                                .padding(20)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(20)
                            } else {
                                ForEach(contact.recurringEvents?.allObjects as? [RecurringEvents] ?? [] , id: \.self) { reEvent in //
                                    HStack(alignment: .center) {
                                        Image(systemName: "goforward")
                                            .font(.title2)
                                            .padding(.trailing)
                                        
                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack() {
                                                Text(reEvent.name ?? "undefine name")
                                                    .font(.body)
                                                
                                                Spacer()
                                                
                                            }
                                            
                                            HStack {
                                                Text(reEvent.date ?? Date(), style: .date)
                                                Text(reEvent.date ?? Date(), style: .time)
                                                Text(contactManager.printRhymus(reEvent.rhymus))
                                                Spacer()
                                            }
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                        }
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Confirm(message: "'\( reEvent.name ?? "" )' löschen?", buttonText: "", buttonIcon: "trash", content: {
                                            Button("Löschen") {
                                               // eventManager.deleteRecurringEvents(reEvent)
                                                eventManager.deleteRecurringAllEvents(reEvent)
                                            }
                                            .foregroundColor(.white)
                                        })
                                        .foregroundColor(.white)
                                    }
                                    .padding(20)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(20)
                                    
                                }
                            }
                            
                        }
                    }
                    .padding(.top, 50)
                    
                    ContactCardComponent(color: iconColor, contact: contact)
                        .padding(.top, 50)
                    
                }
            }
            .padding(.horizontal)
            .fullSizeTop()
            .sheet(isPresented: $contactManager.isShowAddContactPersonSheet, content: {
                AddContactPersonSheet()
            })
            .sheet(isPresented: $contactManager.isShowAddContactRhymusSheet, content: {
                AddContactRecurringEvents()
                    .presentationDragIndicator(.visible)
            })
        }
        .fullSizeTop()
    }

    // MARK: - AddContactPersonSheet
    @ViewBuilder
    func AddContactPersonSheet() -> some View {
        ZStack{
            appConfig.backgroundGradient
                .ignoresSafeArea()
            
            VStack(){
                Text("Ansprechspartner hinzufügen!")
                    .padding(.top)
                
                Form {
                    Section {
                        Picker("Anrede", selection: $contactManager.title) {
                            Text("---").tag("---")
                            Text("Herr").tag("Herr")
                            Text("Frau").tag("Frau")
                        }
                        
                        HStack{
                            Text("Vorname:")
                            
                            TextField( text: $contactManager.firstname, prompt: Text("Max")) {
                                   Text("Vorname")
                               }
                            .disableAutocorrection(true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        HStack{
                            Text("Nachname:")
                            
                            Spacer()
                            
                            TextField( text: $contactManager.lastname, prompt: Text("Musterman")) {
                                   Text("Nachname")
                               }
                            .disableAutocorrection(true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack{
                            Text("Telefon:")
                            
                            Picker("", selection: $contactManager.countryPhonePrefix) {
                                ForEach(contactManager.counntrys, id: \.identifier) { c in
                                    Text("\(c.identifier) (\(c.prefix))").tag("\(c.identifier)")
                                }
                            }
                            
                            TextField( text: $contactManager.phone, prompt: Text("Telefon Nr.")) {
                                Text("040 / 1234")
                            }
                            .disableAutocorrection(true)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack{
                            Text("Mobil:")
                            
                            Picker("", selection: $contactManager.countryMobilPrefix) {
                                ForEach(contactManager.counntrys, id: \.identifier) { c in
                                    Text("\(c.identifier) (\(c.prefix))").tag("\(c.identifier)")
                                }
                            }
                            
                            TextField( text: $contactManager.mobil, prompt: Text("Mobil Nr.")) {
                                Text("0174 / 123 456")
                            }
                            .disableAutocorrection(true)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack{
                            Text("E-Mail:")
                            
                            Spacer()
                            
                            TextField( text: $contactManager.email, prompt: Text("E-Mail:")) {
                                Text("info@email.de")
                            }
                            .disableAutocorrection(true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    }
                    .padding(10)
                    .listRowBackground(Color.white.opacity(0.05))
                    .foregroundColor(appConfig.fontColor)

                    Section {
                        HStack {
                            /*
                            Button("Abbrechen") {
                                contactManager.isShowAddContactPersonSheet = false
                                contactManager.resetStates()
                            }
                            .listRowBackground(Color.white.opacity(0.1))
                            */
                            
                            Spacer()
                            
                            Button("Speichern") {
                                contactManager.contactPersonErrors.removeAll(keepingCapacity: true)
                                
                                let newContactPerson = ContactPerson(context: PersistenceController.shared.container.viewContext)
                                newContactPerson.title = contactManager.title
                                newContactPerson.firstname = contactManager.firstname
                                newContactPerson.lastname = contactManager.lastname
                                newContactPerson.phone = convertPhoneNumberWithPrefix(number: contactManager.phone, type: "phone")
                                newContactPerson.mobil = convertPhoneNumberWithPrefix(number: contactManager.mobil, type: "mobil")
                                newContactPerson.mail = contactManager.email
                                
                                //print(convertPhoneNumberWithPrefix(number: contactManager.phone, type: "phone"))
                                
                                if ValidateForm(newContactPerson: newContactPerson) {
                                   
                                    contact.addToContactPersons(newContactPerson)
                                    withAnimation{
                                        eventManager.sortAllEvents()
                                       // focusedTask = newTask
                                    }
                                    do {
                                        try PersistenceController.shared.container.viewContext.save()
                                        contactManager.isShowAddContactPersonSheet = false
                                        contactManager.resetStates()
                                    } catch {
                                        let nsError = error as NSError
                                        fatalError("Add Task error: \(nsError), \(nsError.userInfo)")
                                    }
                                    
                                } else {
                                    print("not Valid")
                                }

                            }
                            
                        }
                        .padding(10)
                        .listRowBackground(Color.white.opacity(0.05))
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                    .foregroundColor(appConfig.fontColor)
                    .onAppear{
                        contactManager.countryPhonePrefix = Locale.current.language.region!.identifier
                        contactManager.countryMobilPrefix = Locale.current.language.region!.identifier
                    }
                    .onChange(of: contactManager.phone, perform: { newPhone in
                        let _ = convertPhoneNumberWithPrefix(number: newPhone, type: "phone")
                        //print(p)
                    })
                    .onChange(of: contactManager.countryPhonePrefix, perform: { newPhone in
                        let _ =  convertPhoneNumberWithPrefix(number: contactManager.phone, type: "phone")
                        //print(p)
                    })
                    .onChange(of: contactManager.mobil, perform: { newPhone in
                        let _ =  convertPhoneNumberWithPrefix(number: newPhone, type: "mobil")
                       // print(p)
                    })
                    .onChange(of: contactManager.countryMobilPrefix, perform: { newPhone in
                        let _ =  convertPhoneNumberWithPrefix(number: contactManager.mobil, type: "mobil")
                       // print(p)
                    })
                    
                    
                    if contactManager.contactPersonErrors.count > 0 {
                        PrintErrors()
                    }
                   
                }
                
                Spacer()
            }
            .padding(.vertical, 10)
            .scrollContentBackground(.hidden)
            .foregroundColor(.white)
            
        }
        .fullSizeTop()
    }
    
    // MARK: - AddContactRecurringEvents
    @ViewBuilder
    func AddContactRecurringEvents() -> some View {
        ZStack{
            appConfig.backgroundGradient
                .ignoresSafeArea()
            
            VStack(){
                Text("Wiederholende Erreignisse hinzufügen")
                    .padding(.top)
                
                Form {
                    VStack {
                        VStack(alignment: .leading){
                            HStack{
                                Text("Name:")
                                TextField( text: $contactManager.RecurringEventName, prompt: Text("Name")) {
                                       Text("Name")
                                   }
                                .disableAutocorrection(true)
                               
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("Bitte Name angeben!")
                                .foregroundColor(.red)
                                .font(.caption)
                                .opacity( contactManager.RecurringEventName == "" ? 1 : 0)
                        }
                        
                        VStack(alignment: .leading){
                            HStack{
                                Picker("Rhytmus", selection: $contactManager.RecurringEventRhytmus) {
                                    Text("Wöchentlich").tag(604800.0).font(.caption2)
                                    Text("Monatlich").tag(1209600.0).font(.caption2)
                                    Text("Quatal").tag(2630000.0).font(.caption2)
                                    Text("Halbjährlich").tag(7890000.0).font(.caption2)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            HStack{
                                Text("Datum:")
                                
                                Spacer()
                                
                                Button {
                                    withAnimation {
                                        contactManager.showDatePicker.toggle()
                                    }
                                } label: {
                                    HStack(spacing: 20){
                                        Image(systemName: "calendar.badge.plus")
                                            .font(.title3)
                                        Text(contactManager.addRecurringEventDate, style: .date)
                                    }
                                    .padding()
                                }
                                .background(
                                    HStack{
                                        DatePicker("", selection: $contactManager.addRecurringEventDate, displayedComponents: .date)
                                            .datePickerStyle(.wheel)
                                            .frame(width: 300, height: 100)
                                            .clipped()
                                            .background(Color.gray.cornerRadius(10))
                                    }
                                    .offset(x: -50, y: 90)
                                    .opacity(contactManager.showDatePicker ? 1 : 0 )
                                    .frame(maxWidth: .infinity)
                                )
                                
                            }
                            .onTapGesture {
                                contactManager.showDatePicker = true
                            }
                            
                            HStack{
                                Text("Zeit:")
                                
                                Spacer()
                                
                                Button {
                                    withAnimation {
                                        contactManager.showTimePicker.toggle()
                                    }
                                } label: {
                                    HStack(spacing: 20){
                                        Image(systemName: "calendar.badge.plus")
                                            .font(.title3)
                                        Text(contactManager.addRecurringEventDate, style: .time)
                                    }
                                    .padding()
                                }
                                .background(
                                    HStack{
                                        DatePicker("", selection: $contactManager.addRecurringEventDate, displayedComponents: .hourAndMinute)
                                            .datePickerStyle(.wheel)
                                            .frame(width: 200, height: 100)
                                            .clipped()
                                            .background(Color.gray.cornerRadius(10))
                                            
                                    }
                                    .offset(x: -25, y: 90)
                                    .opacity(contactManager.showTimePicker ? 1 : 0 )
                                    .frame(maxWidth: .infinity)
                                )
                                
                            }
                            .onTapGesture {
                                contactManager.showTimePicker = true
                            }
                        }
                        .padding(.bottom, 250)
                    }
                    .padding(10)
                    .listRowBackground(Color.white.opacity(0.05))
                    .foregroundColor(appConfig.fontColor)
                    
                    Section {
                        HStack {
                            Button("Abbrechen") {}
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                                
                            Spacer()
                            
                            Button("Speichern") {
                                guard contactManager.RecurringEventName != "" else {
                                    contactManager.errors.append("Bitte gebe eine RecurringEventName ein!")
                                    return print( "Bitte gebe eine RecurringEventName ein!")
                                }
                                guard contactManager.RecurringEventRhytmus != 0.0 else {
                                    contactManager.errors.append("Bitte gebe eine RecurringEventRhytmus ein!")
                                    return print( "Bitte gebe eine RecurringEventRhytmus ein!")
                                }
                                let ident = contactManager.generateIdentifier()
                                let newRecurringEvents = RecurringEvents(context: PersistenceController.shared.container.viewContext)
                                    newRecurringEvents.identifier = ident
                                    newRecurringEvents.name = contactManager.RecurringEventName
                                    newRecurringEvents.rhymus = contactManager.RecurringEventRhytmus
                                newRecurringEvents.date = contactManager.addRecurringEventDate
                                    contact.addToRecurringEvents(newRecurringEvents)
                                
                                if contactManager.RecurringEventRhytmus != 0 {
                                    let id:String = ident
                                    let titel:String = "Pro Prothese - Reminder"
                                    let body:String = "Erinnerung: \(newRecurringEvents.name ?? "Unknown Name")"
                                    let rhytmus:Double = newRecurringEvents.rhymus
                                    pushNotificationManager.PushNotificationRepeater(identifier: id, title: titel, body: body, interval: rhytmus)
                                }

                                do {
                                    
                                    
                                    // Save Event in Device Calendar
                                    FK_EventProvider.shared.insertRecurringEvent(store: EKEventStore(), event: newRecurringEvents, completionHandler: { res in
                                        //newEvent.eventID = res
                                        print(res)
                                        //events.append(newEvent)
                                    })
                                    
                                    try PersistenceController.shared.container.viewContext.save()
                                    
                                    contactManager.isShowAddContactRhymusSheet = false
                                    contactManager.RecurringEventName = ""
                                    contactManager.RecurringEventRhytmus = 0
                                    contactManager.errors.removeAll(keepingCapacity: true)
                                    
                                } catch {
                                    let nsError = error as NSError
                                    fatalError("Add Task error: \(nsError), \(nsError.userInfo)")
                                }
                            }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(withAnimation{
                                    contactManager.RecurringEventSubmit ? Color.white.opacity(0.05) : Color.white.opacity(0.1)
                                })
                                .cornerRadius(10)
                                .disabled(contactManager.RecurringEventSubmit)
                        }
                       
                    }
                    .listRowBackground(Color.white.opacity(0.025))
                    .foregroundColor(appConfig.fontColor)
                }
                
                Spacer()
            }
            .padding(.vertical, 10)
            .scrollContentBackground(.hidden)
            .foregroundColor(.white)
            .onAppear{
                contactManager.addRecurringEventDate = Date()
                contactManager.showDatePicker = false
                contactManager.showTimePicker = false
            }
            .onChange(of: contactManager.addRecurringEventDate) { newValue in
               withAnimation {
                   contactManager.showDatePicker = false
                   contactManager.showTimePicker = false
               }
            }// DatePicker
        }
        .fullSizeTop()
        
    }
    
    @ViewBuilder
    func PrintErrors() -> some View {
        VStack(spacing: 6){
            ForEach(contactManager.contactPersonErrors, id: \.type) { error in
                HStack{
                    Text(error.error)
                        .font(.caption2)
                        .foregroundColor(.red)
                    
                    Spacer()
                }
            }
        }
        .listRowBackground(Color.white.opacity(0.05))
        .padding()
    }
    
    func isValidEmail(value :String) -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: value)
        return result
    }

    func convertPhoneNumberWithPrefix(number: String, type: String) -> String {
         if number.prefix(1) == "+" {

             if type == "phone" {
                 let predix = (contactManager.counntrys.first(where: { $0.identifier == contactManager.countryPhonePrefix })?.prefix)!
                 
                 contactManager.countryPhonePrefix = contactManager.counntrys.first(where: { $0.prefix == number.prefix(3) } )?.identifier ?? "DE"
                 
                 return predix + number.dropFirst(3)
                 
             } else if type == "mobil" {
                 let predix = (contactManager.counntrys.first(where: { $0.identifier == contactManager.countryMobilPrefix })?.prefix)!
                 
                 contactManager.countryMobilPrefix = contactManager.counntrys.first(where: { $0.prefix == number.prefix(3) } )?.identifier ?? "DE"
                 
                 return predix + number.dropFirst(3)
             } else {
                 return ""
             }
            
             
        } else if number.prefix(2) == "00" {

            if type == "phone" {
                
                let predix = (contactManager.counntrys.first(where: { $0.identifier == contactManager.countryPhonePrefix })?.prefix)!
                
                let findNr = number.prefix(4).dropFirst(2)
                
                contactManager.countryPhonePrefix = contactManager.counntrys.first(where: { $0.prefix == "+\(findNr)" } )?.identifier ?? "DE"
                
                var striptedNumber = number.dropFirst(4)
                
                if striptedNumber.prefix(1) == "0" {
                    striptedNumber = striptedNumber.dropFirst()
                }

                return predix + striptedNumber
                
            } else if type == "mobil" {
                
                let predix = (contactManager.counntrys.first(where: { $0.identifier == contactManager.countryMobilPrefix })?.prefix)!
                
                let findNr = number.prefix(4).dropFirst(2)
                
                contactManager.countryMobilPrefix = contactManager.counntrys.first(where: { $0.prefix == "+\(findNr)" } )?.identifier ?? "DE"
                
                var striptedNumber = number.dropFirst(4)
                
                if striptedNumber.prefix(1) == "0" {
                    striptedNumber = striptedNumber.dropFirst()
                }

                return predix + striptedNumber
            } else {
                return ""
            }

        } else if number.prefix(1) == "0" {
            
            if type == "phone" {
                contactManager.countryPhonePrefix = contactManager.countryPhonePrefix
                return (contactManager.counntrys.first(where: { $0.identifier == contactManager.countryPhonePrefix })?.prefix)! + number.dropFirst()
            } else if type == "mobil" {
                contactManager.countryMobilPrefix = contactManager.countryMobilPrefix
                return (contactManager.counntrys.first(where: { $0.identifier == contactManager.countryMobilPrefix })?.prefix)! + number.dropFirst()
            } else {
                return ""
            }

        } else {
            return ""
        }
        
    }

    func ValidateForm(newContactPerson : ContactPerson) -> Bool {
        if newContactPerson.title == "---" { contactManager.contactPersonErrors.append((type: "title", error: "Bitte wähle eine Anrede")) }

        if newContactPerson.firstname!.count < 3 { contactManager.contactPersonErrors.append((type: "firstname", error: "Der Vorname sollte mindestens 3 Buchstaben haben.")) }
        
        if newContactPerson.lastname!.count < 3 { contactManager.contactPersonErrors.append((type: "lastname", error: "Der Nachname sollte mindestens 3 Buchstaben haben.")) }
        
        if newContactPerson.phone!.count < 5 { contactManager.contactPersonErrors.append((type: "phone", error: "Die Telefon Nr. ist nicht Korrekt.")) }
        
        if newContactPerson.mobil!.count > 0 && newContactPerson.mobil!.count < 5 { contactManager.contactPersonErrors.append((type: "mobil", error: "Die Mobil Nr. ist nicht Korrekt.")) }
        
        if isValidEmail(value: newContactPerson.mail!) != true { contactManager.contactPersonErrors.append((type: "mail", error: "Die E-Mail ist nicht Korrekt.")) }
        
        return contactManager.contactPersonErrors.count == 0 ? true : false
    }
}

extension String {
    func isValidPhoneNumber() -> Bool {
        let regEx = "^\\+(?:[0-9]?){6,14}[0-9]$"

        let phoneCheck = NSPredicate(format: "SELF MATCHES[c] %@", regEx)
        return phoneCheck.evaluate(with: self)
    }
}
