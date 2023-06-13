//
//  ProProtheseWidget.swift
//  ProProtheseWidget
//
//  Created by Frederik Kohler on 13.06.23.
//

import WidgetKit
import SwiftUI

struct PainProvider: TimelineProvider {
    let url = URL(string: "ProProthese://pain")
    
    func placeholder(in context: Context) -> PainSimpleEntry {
        PainSimpleEntry(date: Date(), url: url)
    }

    func getSnapshot(in context: Context, completion: @escaping (PainSimpleEntry) -> ()) {
        let entry = PainSimpleEntry(date: Date(), url: url)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [PainSimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = PainSimpleEntry(date: Date(), url: url)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct PainSimpleEntry: TimelineEntry {
    let date: Date
    let url: URL?
}

struct ProProtheseWidgetPainEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: PainProvider.Entry

    var body: some View {
        ZStack {
            Link(destination: URL(string: "ProProthese://feeling")!) {
                
                LinearGradient(colors: [Color(red: 32/255, green: 40/255, blue: 63/255), Color(red: 4/255, green: 5/255, blue: 8/255)], startPoint: .top, endPoint: .bottom)
                
                switch widgetFamily {
                case .systemSmall:
                    GeometryReader { screen in
                        
                        let width = screen.size.width / 2
                        
                        VStack {
                            
                            Text("Hey, hast du Schmerzen heute?")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                            
                            ZStack{
                                Circle()
                                    .fill(.yellow)
                                    .frame(width: width, height: width)
                                
                                Image(systemName: "plus")
                                    .font(.title.bold())
                                    .foregroundColor(.black)
                            }
                            .widgetURL(URL(string: "ProProthese://pain"))
                        }
                        .frame(width: screen.size.width, height: screen.size.height)
                        .widgetURL(entry.url)
                        
                    }
                case .systemLarge:
                    VStack {
                        Text(entry.date, style: .time)
                        Text("Large Widget")
                    }
                default:
                    VStack {
                        Text(entry.date, style: .time)
                        Text("Default")
                    }
                }
            }
        }
    }
}

struct ProProtheseWidgetPain: Widget {
    let kind: String = "ProProtheseWidgetPain"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PainProvider()) { entry in
            ProProtheseWidgetPainEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("Phantomschmerzen?")
        .description("Dokumentiere deine Schmerzen schnell und unkompliziert.")
    }
}

struct ProProtheseWidgetPain_Previews: PreviewProvider {
    static var previews: some View {
        ProProtheseWidgetPainEntryView(entry: PainSimpleEntry(date: Date(), url: URL(string: "ProProthese://pain")))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
