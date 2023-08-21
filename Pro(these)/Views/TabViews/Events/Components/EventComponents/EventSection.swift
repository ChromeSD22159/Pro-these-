//
//  EventSection.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 04.05.23.
//

import SwiftUI

struct EventSection: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @State private var count = 0
    
    private var titel: LocalizedStringKey
    
    @FetchRequest var allEvents: FetchedResults<Event>
    
    var data: [Event] {
        return self.allEvents.sorted(by: { $0.startDate ?? Date() < $1.startDate ?? Date() })
    }
    
    private var type: eventSection
    
    private var viewType: eventSection.viewType
    
    @State var isExtended: Bool = false
    
    init(type: eventSection, viewType: eventSection.viewType? = .section, isExtended: Bool? = false) {
        _allEvents = FetchRequest<Event>(
            sortDescriptors: [],
            predicate: type.predicate
        )
        
        self.type = type
        self.titel = type.titel
            
        self.viewType = viewType!
        self.isExtended = isExtended!
    }
    
    var body: some View {
        if viewType == .section {
            sectionView()
        }
        
        if viewType == .diclosure {
            diclosureView()
        }
        
    }
    
    @ViewBuilder func sectionView() -> some View {
        Section(content: {
            
            contentBody()
            
        }, header: {
            contentHeader()
        })
        .tint(currentTheme.text)
        .listRowBackground(currentTheme.text.opacity(0.05))
        .listRowInsets(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
        .onAppear{
            count = data.count
        }
        .onChange(of: data, perform: { newData in
            count = newData.count
        })
    }
    
    @ViewBuilder func diclosureView() -> some View {
        DisclosureGroup(
            isExpanded: $isExtended.animation(.easeInOut(duration: 0.35)),
            content: {
                contentBody()
            }, label: {
                contentHeader()
        })
        .tint(currentTheme.text)
        .listRowBackground(currentTheme.text.opacity(0.05))
        .listRowInsets(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
        .onAppear{
            count = data.count
        }
        .onChange(of: data, perform: { newData in
            count = newData.count
        })
    }
    
    @ViewBuilder func contentHeader() -> some View {
        HStack{
            HStack(spacing: 2) {
                Text(titel)
                    .font(.caption2)
                    .fontWeight(.medium)
                
                Text("(\(count))")
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            
            Spacer()
             
            if viewType == .section {
                Button(
                    action: {
                        eventManager.openAddEventSheet(date: Date())
                    }, label: {
                        Label("Termin", systemImage: "plus")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.trailing, 20)
                    })
            }
          
        }
    }
    
    @ViewBuilder func contentBody() -> some View {
        if allEvents.isEmpty {
            Text(type.noEvents)
                .font(.caption2)
                .fontWeight(.medium)
        } else {
            ForEach(data){ item in
                NavigateTo({
                    EventPreview(item: item)
                }, {
                    EventDetailView( iconColor: currentTheme.hightlightColor, item: item)
                })
            }
        }
    }
}


struct EventSection_Previews: PreviewProvider {
    
    static var testEvent: Event? {
        let newEvent = Event(context: PersistenceController.shared.container.viewContext)
        newEvent.icon = ""
        newEvent.titel = "Standrort Gespräch"
        newEvent.endDate = Date()
        newEvent.startDate = Date()
        
        return newEvent
    }
        
    static var previews: some View {
        ZStack {
            Theme.blue.gradientBackground(nil).ignoresSafeArea()
            
            VStack(spacing: 20) {
                EventSection(type: .thisWeek)
                
                EventSection(type: .thisMonth)

            }
            .padding()
            .environmentObject(AppConfig())
            .environmentObject(TabManager())
            .environmentObject(HealthStorage())
            .environmentObject(PushNotificationManager())
            .environmentObject(EventManager())
            .environmentObject(MoodCalendar())
            .environmentObject(WorkoutStatisticViewModel())
            .environmentObject(PainViewModel())
            .environmentObject(StateManager())
            .environmentObject(EntitlementManager())
            .defaultAppStorage(UserDefaults(suiteName: "group.FK.Pro-these-")!)
            .colorScheme(.dark)
            
            
        }
    }
}

extension EventSection {
    enum eventSection: Codable, Hashable {
        case thisWeek
        case lastWeek
        case nextWeek
        case thisMonth
        case nextMonth
        case all
        case past
        
        var titel: LocalizedStringKey {
            switch self {
            case .thisMonth: return "This Month"
            case .nextMonth: return "Next Month"
            case .thisWeek: return "This Week"
            case .nextWeek: return "Next Week"
            case .lastWeek: return "Last week"
            case .all: return "All appointments"
            case .past: return "Past appointments"
            }
        }
        
        var noEvents: LocalizedStringKey {
            switch self {
            case .thisMonth: return "No events for this month!"
            case .nextMonth: return "No events for next month!"
            case .thisWeek: return "No events for this week!"
            case .nextWeek: return "No events for next week!"
            case .lastWeek: return "There were no events last week!"
            case .all: return "All appointments"
            case .past: return "Past appointments"
            }
        }
        
        var predicate: NSPredicate {
            switch self {
            case .thisWeek:
                let date = Date()
                return NSPredicate(format: "(startDate >= %@) AND (startDate <= %@)", date.startEndOfDay().start as CVarArg, date.startEndOfWeek.end as CVarArg)
                
            case .nextMonth:
                let nextmonth = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
                return NSPredicate(format: "(startDate >= %@) AND (startDate <= %@)", nextmonth.startEndOfMonth.start as CVarArg, nextmonth.startEndOfMonth.end as CVarArg)
                
            case .lastWeek:
                let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
                return NSPredicate(format: "(startDate >= %@) AND (startDate <= %@)", lastWeek.startEndOfWeek.start as CVarArg, lastWeek.startEndOfWeek.end as CVarArg)
                
            case .nextWeek:
                let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
                return NSPredicate(format: "(startDate >= %@) AND (startDate <= %@)", nextWeek.startEndOfWeek.start as CVarArg, nextWeek.startEndOfWeek.end as CVarArg)
                
            case .thisMonth:
                let thisMonth: Date = Date()
                return NSPredicate(format: "(startDate >= %@) AND (startDate <= %@)", thisMonth.startEndOfMonth.start as CVarArg, thisMonth.startEndOfMonth.end as CVarArg)
                
            case .all: return NSPredicate()
                
            case .past:
                let date = Date()
                return NSPredicate(format: "startDate <= %@", date as CVarArg)
            }
        }
        
        enum viewType {
            case section, diclosure
        }
    }
}
