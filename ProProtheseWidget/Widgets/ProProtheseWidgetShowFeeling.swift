//
//  ProProtheseWidget.swift
//  ProProtheseWidget
//
//  Created by Frederik Kohler on 13.06.23.
//

import WidgetKit
import SwiftUI
import Foundation
import CoreData

struct ShowFeelingProvider: TimelineProvider {
    
    let url = URL(string: "ProProthese://showFeeling")
    
    var nextUpdate: Date {
        return Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    }
    
    func placeholder(in context: Context) -> ShowFeelingSimpleEntry {
        ShowFeelingSimpleEntry(date: Date(), nextUpdate: Date(), url: url, feelings: try! fetchFeelings())
    }

    func getSnapshot(in context: Context, completion: @escaping (ShowFeelingSimpleEntry) -> ()) {
        let entry = ShowFeelingSimpleEntry(date: Date(), nextUpdate: Date(), url: url, feelings: try! fetchFeelings())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entrie = ShowFeelingSimpleEntry(date: Date(), nextUpdate: nextUpdate, url: url, feelings: try! fetchFeelings())
        
        let timeline = Timeline(entries: [entrie], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func fetchFeelings() throws -> [Feeling]{
        let context = PersistenceController.shared.container.viewContext
        
        let request = Feeling.fetchRequest()
        let result = try context.fetch(request)
        
        return result
    }
}

struct ShowFeelingSimpleEntry: TimelineEntry {
    let date: Date
    let nextUpdate: Date
    let url: URL?
    let feelings: [Feeling]
}

struct ProProtheseWidgetShowFeelingEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: ShowFeelingProvider.Entry

    private let debug = true
    
    @State var week: [(weekday: String, date: Date)] = []
    
    var body: some View {
        ZStack {
            Link(destination: entry.url!) {
                
                LinearGradient(colors: [Color(red: 32/255, green: 40/255, blue: 63/255), Color(red: 4/255, green: 5/255, blue: 8/255)], startPoint: .top, endPoint: .bottom)
                
                switch widgetFamily {
                case .systemSmall:
                    ViewThatFits {
                        
                        VStack(alignment: .center, spacing: 5){
                            Text("Hey, Wie fühlst du dich heute?")
                                .font(.caption.bold())
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            DayButton(convertDateToDayNames(entry.date), entry.date, entry.feelings)

                        }
                        
                    }
                    .padding()
                    
                case .systemMedium:
                    ViewThatFits {
                        
                        VStack(spacing: 5){
                            
                            let date = entry.date.dateFormatte(date: "dd.MM.YYYY", time: "").date
                            let weekday = convertDateToDayNames(entry.date)
                            
                            HStack {
                                Text("Pro Prothese")
                                    .font(.caption.bold())
                                
                                Spacer()
                                
                                Text("\(weekday), \(date)")
                                    .font(.caption.bold())
                            }
                            
                            HStack{
                                Text("So fühlst du dich heute mit deiner Prothese.")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                            }
                            
                            Spacer()
                            
                            HStack{
                                ForEach(extractWeekByDate(currentDate: Date()), id: \.date) { weekday, date in
                                    DayButton(weekday, date, entry.feelings)
                                }
                            }
                        }
                        
                    }
                    .padding()
                    .widgetURL(entry.url)
                default:
                    VStack {
                        Text(entry.date, style: .time)
                            .font(.caption.bold())
                        Text("Default")
                    }
                }
            }
        }
        .onAppear{
           week = extractWeekByDate(currentDate: Date())
        }
    }
    
    @ViewBuilder // MARK: - Calendar Day Circle
    func DayButton(_ weekday: String, _ date: Date, _ feelings: [Feeling]) -> some View {
        VStack(alignment: .center, spacing: 2) {
            Text("\(weekday).")
                .font(.caption2)
                .foregroundColor(.gray)
            
            ZStack {
                
                if let _ = feelings.first(where: { return isSameDay(d1: $0.date ?? Date(), d2: date) }) {
                    
                    let fe = feelings.map( { return  isSameDay(d1: $0.date ?? Date(), d2: date) ? Int(($0.name?.trimFeelings()) ?? "") : nil } )
                    if fe.count > 0 {
                        
                        let avg:Int = fe.compactMap{ $0 }.reduce(0, +) / fe.compactMap{ $0 }.count
                        
                        Image("chart_feeling_" + String(avg) )
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color.gray)
                            .imageScale(.large)
                            .clipShape(Circle())
                            .widgetURL(URL(string: "ProProthese://showFeeling"))
                    }
                    
                } else {
                    Circle()
                        .fill(.white.opacity(0.1))
                        .scaledToFit()
                        .clipShape(Circle())
                    
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .widgetURL(URL(string: "ProProthese://addFeeling"))
                }
                
            }
            .background(.gray.opacity(0.1))
            .cornerRadius(500)
            
            
            Text(date.dateFormatte(date: "dd", time: "").date)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
    
    func extractWeekByDate(currentDate: Date) -> [(weekday: String, date: Date)] {
        var ArrWeek: [(weekday: String, date: Date)] = []
        
        let firstDayOfWeek = Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: currentDate).date!
        
        for day in 0..<7 {
            if let weekDay = Calendar.current.date(byAdding: .day, value: day, to: firstDayOfWeek) {
                let date =  Calendar.current.date(byAdding: .hour, value: 2, to: weekDay)
                ArrWeek.append( (weekday: convertDateToDayNames(date!) , date: date!) )
            }
        }
        
        return ArrWeek
    }
    
    func convertDateToDayNames(_ date: Date) -> String {
        
        let day = date.dateFormatte(date: "EEEE", time: "HH:mm").date
        
        switch day {
        case "Monday": return "Mo"
        case "Tuesday": return "Di"
        case "Wednesday": return "Mi"
        case "Thursday": return "Do"
        case "Friday": return "Fr"
        case "Saturday": return "Sa"
        case "Sunday": return "So"
        default:
            return ""
        }
    }
    
    func isSameDay(d1: Date, d2: Date) -> Bool {
       return Calendar.current.isDate(d1, inSameDayAs: d2)
    }
    
}

struct ProProtheseWidgetShowFeeling: Widget {
    let kind: String = "ProProtheseWidgetShowFeeling"
    
    let supportedFamilies:[WidgetFamily] = [
        .systemSmall,
        .systemMedium
    ]
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ShowFeelingProvider()) { entry in
            ProProtheseWidgetShowFeelingEntryView(entry: entry)
        }
        .supportedFamilies(supportedFamilies)
        .configurationDisplayName("Feelings im Überblick")
        .description("Sehe deine Feelings.")
      
    }
}

extension String {
    func trimCharater () -> String {
        return self.trimmingCharacters(in: ["("," ",":","\"",")"])
    }
    
    func trimFeelings () -> String {
        return self.trimmingCharacters(in: ["_", "f", "e" ,"l","i","n","g"])
    }
    
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
