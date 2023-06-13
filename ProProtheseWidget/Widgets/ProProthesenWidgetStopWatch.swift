//
//  ProProtheseWidget.swift
//  ProProtheseWidget
//
//  Created by Frederik Kohler on 13.06.23.
//

import WidgetKit
import SwiftUI

struct StopWatchProvider: TimelineProvider {
    func placeholder(in context: Context) -> StopWatchSimpleEntry {
        StopWatchSimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (StopWatchSimpleEntry) -> ()) {
        let entry = StopWatchSimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [StopWatchSimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = StopWatchSimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct StopWatchSimpleEntry: TimelineEntry {
    let date: Date
}

struct ProProthesenWidgetStopWatchEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: StopWatchProvider.Entry

    var body: some View {
        
        Link(destination: URL(string: "ProProthese://stopWatch")!) {
            ZStack {
                
                LinearGradient(colors: [Color(red: 32/255, green: 40/255, blue: 63/255), Color(red: 4/255, green: 5/255, blue: 8/255)], startPoint: .top, endPoint: .bottom)
                
                switch widgetFamily {
                case .systemSmall:
                    GeometryReader { screen in
                        
                        let width = screen.size.width / 2
                        
                        VStack {
                            
                            Text("Kontrolliere deinen Prothesentimer.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)

                            ZStack{
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: width, height: width)
                                
                                Image(systemName: "playpause.fill")
                                    .font(.title.bold())
                                    .foregroundColor(.yellow)
                            }
                        }
                        .frame(width: screen.size.width, height: screen.size.height)
                        
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
            }.widgetURL(URL(string: "ProProthese://stopWatch"))
        }
        
       
    }
}

struct ProProthesenWidgetStopWatch: Widget {
    let kind: String = "ProProthesenWidgetStopWatch"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StopWatchProvider()) { entry in
            ProProthesenWidgetStopWatchEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("Prothese Tragezeiten")
        .description("Stoppe deine Prothesen tragezeiten.")
    }
}

struct ProProthesenWidgetStopWatch_Previews: PreviewProvider {
    static var previews: some View {
        ProProthesenWidgetStopWatchEntryView(entry: StopWatchSimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
