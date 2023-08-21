//
//  ProProtheseWidget.swift
//  ProProtheseWidget
//
//  Created by Frederik Kohler on 13.06.23.
//

import WidgetKit
import SwiftUI

struct PainProvider: TimelineProvider {
    let url = URL(string: "ProProthese://addPain")
    
    let unlocked: Bool
    
    func placeholder(in context: Context) -> PainSimpleEntry {
        PainSimpleEntry(date: Date(), url: url, hasUnlockedPro: unlocked)
    }

    func getSnapshot(in context: Context, completion: @escaping (PainSimpleEntry) -> ()) {
        let entry = PainSimpleEntry(date: Date(), url: url, hasUnlockedPro: unlocked)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [PainSimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = PainSimpleEntry(date: entryDate, url: url, hasUnlockedPro: unlocked)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct PainSimpleEntry: TimelineEntry {
    let date: Date
    let url: URL?
    let hasUnlockedPro: Bool
}

struct ProProtheseWidgetPainEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    
    private var currentTheme: Theme {
        return ThemeManager().currentTheme()
    }
    
    var entry: PainProvider.Entry

    var body: some View {
        ZStack {
            hasProFeatureOverlay(binding: !entry.hasUnlockedPro, label: true) { state in
                Link(destination: entry.hasUnlockedPro ? entry.url! : URL(string: "ProProthese://getPro")! ) {

                    currentTheme.gradientBackground(nil)
                    
                    switch widgetFamily {
                    case .systemSmall:
                        GeometryReader { screen in
                            
                            let width = screen.size.width / 2
                            
                            VStack {
                                
                                Text("Hey, are you in pain today?")
                                    .font(.caption.bold())
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(currentTheme.hightlightColor)
                                    .padding(.horizontal)
                                
                                ZStack{
                                    Circle()
                                        .fill(currentTheme.text.opacity(0.1))
                                        .frame(width: width, height: width)
                                    
                                    Image(systemName: "plus")
                                        .font(.title.bold())
                                        .foregroundColor(currentTheme.hightlightColor)
                                }
                                .widgetURL(entry.hasUnlockedPro ? entry.url! : URL(string: "ProProthese://getPro")! )
                            }
                            .frame(width: screen.size.width, height: screen.size.height)
                            .hasProBlurry(state)
                            
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
        .widgetURL(entry.hasUnlockedPro ? entry.url! : URL(string: "ProProthese://getPro")!)
    }
}

struct ProProtheseWidgetPain: Widget {
    let kind: String = "ProProtheseWidgetPain"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PainProvider(unlocked: AppTrailManager.hasProOrFreeTrail)) { entry in 
            ProProtheseWidgetPainEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("Phantom limb pains?")
        .description("Document your pain quickly and easily.")
    }
}

struct ProProtheseWidgetPain_Previews: PreviewProvider {
    static var previews: some View {
        ProProtheseWidgetPainEntryView(entry: PainSimpleEntry(date: Date(), url: URL(string: "ProProthese://pain"), hasUnlockedPro: true))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
