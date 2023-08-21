//
//  EventProvider.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 16.05.23.
//

import EventKit
import EventKitUI

class FK_EventProvider {

    static let shared = FK_EventProvider()
    
    let eventStore = EKEventStore()
    
    var isAvailable: Bool {
         EKEventStore.authorizationStatus(for: .reminder) == .authorized
     }

    func requestAccess(store: EKEventStore) -> EKAuthorizationStatus {
        switch EKEventStore.authorizationStatus(for: .event) {
            case .denied, .restricted: print("Access denied")
            case .notDetermined:  print("Access denied")
            case .authorized: print("Access to EventStore")
            default:  break
        }
        return EKEventStore.authorizationStatus(for: .event)
    }
    
    func insertEvent(store: EKEventStore, event: Event, alarm: Int, completionHandler: (String) -> Void) {
        store.requestAccess(to: .event) { granted, error in
            // Handle the response to the request.
        }
        
        guard self.requestAccess(store: store) == .authorized else {
            return
        }

        let newEvent = EKEvent(eventStore: store)
        newEvent.calendar = store.defaultCalendarForNewEvents
        newEvent.title = "\(event.titel ?? AppConfig.shared.EventTitelUnknown) bei \(event.contact?.name ??  AppConfig.shared.ContactTitelUnknown)"
        newEvent.startDate = event.startDate
        newEvent.endDate = event.endDate
        //newEvent.url = URL(string: "ProProthese://event")
        newEvent.url = URL(string: "https://www.prothese.pro")
        newEvent.notes = "Erstellt von Pro Prothesen App"
        
        if alarm != 0 {
            let alarm = EKAlarm(relativeOffset: TimeInterval(alarm))
            newEvent.addAlarm(alarm)
        }
        
        guard self.checkEventExists(store: store, event: newEvent) != true else {
            print("Event Already exist")
            return
        }

        do {
            try store.save(newEvent, span: .thisEvent)
            completionHandler(newEvent.eventIdentifier)
        } catch {
           print("Error saving event in calendar")
        }
    }

    func insertRecurringEvent(store: EKEventStore, event: RecurringEvents, completionHandler: (String) -> Void) {
        let newEvent = EKEvent(eventStore: store)
        newEvent.calendar = store.defaultCalendarForNewEvents
        newEvent.title = "\(event.name ?? AppConfig.shared.EventTitelUnknown) bei \(event.contact?.name ??  AppConfig.shared.ContactTitelUnknown)"
        newEvent.startDate = event.date
        newEvent.endDate = event.date
        newEvent.isAllDay = true
        newEvent.addAlarm(EKAlarm(relativeOffset: TimeInterval(-86400)))
        newEvent.recurrenceRules = recurrenceRules(option: convertRhymus(event.rhymus))
        
        //newEvent.calendar = createNewCalendar(withName: "Pro Prothese", store: store)
        newEvent.url = URL(string: "https://www.prothese.pro")
        newEvent.notes = "Erstellt von Pro Prothesen App"
        
        guard self.checkEventExists(store: store, event: newEvent) != true else {
            print("Event Already exist")
            return
        }

        do {
            try store.save(newEvent, span: EKSpan.thisEvent)
            completionHandler(newEvent.eventIdentifier)
        } catch let e as NSError {
            print(e)
            return
        }
        
    }
    
    func convertRhymus(_ rhytmus: Double) -> String {
        switch rhytmus {
            case 0:         return "none"
            case 60.0:      return "none"// 1Minute
            case 300.0:     return "none"// 5Minute
            case 604800.0:  return "Weekly"// Wöchentlich
            case 1209600.0: return "Monthly"// Monatlich
            case 2630000.0: return "EveryQuatal"// Quatal
            case 7890000.0: return "Semiannual"// Halbjährlich
            default: return "none"
        }
    }
    
    func recurrenceRules(option: String) -> [EKRecurrenceRule] {
        switch option {
            case "Daily":

                let rule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.daily, interval: 1, end: nil)

                //daily for 50 years
                return [rule]
            case "Weekly":

                //on the same week day for 50 years
                let rule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.weekly, interval: 1, end: nil)

                return [rule]
            case "Monthly":

                //on the same date of every month
                let rule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.monthly, interval: 1, end: nil)

                return [rule]
            case "EveryQuatal":
                let rule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.monthly, interval: 3, end: nil)

                //daily for 50 years
                return [rule]
            case "Semiannual":
                let rule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.monthly, interval: 6, end: nil)

                //daily for 50 years
                return [rule]

        default:
            return []
        }
    }
    
    func fetchEvent(store: EKEventStore, event: Event) -> [EKEvent] {
        let predicate = store.predicateForEvents(withStart: event.startDate!, end: event.endDate!, calendars: nil)

        let events = store.events(matching: predicate).filter({ $0.title.contains((event.contact?.name)!) })

        // Fetch all events that match the predicate.
        //let events = store.events(matching: predicate)
        
        return events
    }
    
    func fetchRecurringEvents(store: EKEventStore, event: RecurringEvents) -> [EKEvent] {
        let predicate = store.predicateForEvents(withStart: event.date!, end: event.date!, calendars: nil)

        let events = store.events(matching: predicate).filter({ $0.title.contains((event.contact?.name)!) })

        return events
    }
    
    func removeEvent(store: EKEventStore, event: Event) {
        let foundEvent = fetchEvent(store: store, event: event)

        if foundEvent.count > 0 {
            do{
               try store.remove(foundEvent[0], span: EKSpan.thisEvent)
            } catch let e as NSError{
               return print(e)
            }
        }
    }
    
    func removeRecurringEvent(store: EKEventStore, event: RecurringEvents) {
        let foundEvent = fetchRecurringEvents(store: store, event: event)

        if foundEvent.count > 0 {
            do{
               try store.remove(foundEvent[0], span: EKSpan.futureEvents)
            } catch let e as NSError{
               return print(e)
            }
        }
    }
    
    func changeEvent(store: EKEventStore, event: Event, completion: @escaping (_ success: Bool) -> Void) {
        let foundEvent = fetchEvent(store: store, event: event)
        
        let newEvent = foundEvent[0]
        newEvent.title = "\(event.titel ?? AppConfig.shared.EventTitelUnknown) bei \(event.contact?.name ??  AppConfig.shared.ContactTitelUnknown)"
        newEvent.startDate = event.startDate
        newEvent.endDate = event.endDate
        
        if foundEvent.count > 0 {
            do{
                try store.save(foundEvent[0], span: EKSpan.thisEvent)
                completion(true)
            } catch let e as NSError{
                completion(false)
                return print(e)
            }
        }
    }
    
    func removeRecurringAllEvents(store: EKEventStore, event: RecurringEvents) {
            let startDate = NSDate().addingTimeInterval(event.rhymus)
           let endDate = NSDate().addingTimeInterval(event.rhymus)

           let predicate2 = store.predicateForEvents(withStart: startDate as Date, end: endDate as Date, calendars: nil)

            let eV = store.events(matching: predicate2) as [EKEvent]?

           if eV != nil {
               for i in eV! {

                   do{
                       (try store.remove(i, span: EKSpan.futureEvents, commit: true))
                   }
                   catch let error {
                       print("Error removing events: ", error)
                   }

               }
           }
        
    }
    
    func checkEventExists(store: EKEventStore, event eventToAdd: EKEvent) -> Bool {
        let predicate = store.predicateForEvents(withStart: eventToAdd.startDate, end: eventToAdd.endDate ?? Date(), calendars: nil)
        let existingEvents = store.events(matching: predicate)

        let exists = existingEvents.contains { (event) -> Bool in
            return eventToAdd.title == event.title && event.startDate == eventToAdd.startDate && event.endDate == eventToAdd.endDate
        }
        return exists
    }
    
    func createNewCalendar(withName name: String, store: EKEventStore) -> EKCalendar {
        let calendar = EKCalendar(for: .event, eventStore: store)
        calendar.title = name
        calendar.cgColor = Theme.blue.backgroundColor.cgColor

        calendar.source = bestPossibleEKSource(store: store)
        
        return calendar
    }
    
    func bestPossibleEKSource(store: EKEventStore) -> EKSource? {
        let `default` = store.defaultCalendarForNewEvents?.source
        let iCloud = store.sources.first(where: { $0.title == "iCloud" }) // this is fragile, user can rename the source
        let local = store.sources.first(where: { $0.sourceType == .local })

        return `default` ?? iCloud ?? local
    }
}
