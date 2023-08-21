//
//  ProProtheseWidget.swift
//  ProProtheseWidget
//
//  Created by Frederik Kohler on 13.06.23.
//

import WidgetKit
import SwiftUI

struct FeelingProvider: TimelineProvider {
    var unlocked: Bool
    
    func placeholder(in context: Context) -> FeelingSimpleEntry {
        FeelingSimpleEntry(date: Date(), hasUnlockedPro: unlocked)
    }

    func getSnapshot(in context: Context, completion: @escaping (FeelingSimpleEntry) -> ()) {
        let entry = FeelingSimpleEntry(date: Date(), hasUnlockedPro: unlocked)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [FeelingSimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = FeelingSimpleEntry(date: entryDate, hasUnlockedPro: unlocked)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct FeelingSimpleEntry: TimelineEntry {
    let date: Date
    let hasUnlockedPro: Bool
}

struct ProProtheseWidgetFeelingEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily

    var entry: FeelingProvider.Entry

    private var currentTheme: Theme {
        return ThemeManager().currentTheme()
    }
    
    var body: some View {
        
        ZStack {
            hasProFeatureOverlay(binding: !entry.hasUnlockedPro, label: true) { state in
            
                Link(destination: URL(string: !entry.hasUnlockedPro ? "ProProthese://getPro" : "ProProthese://addFeeling")!) {
                    currentTheme.gradientBackground(nil)
                    
                    switch widgetFamily {
                    case .systemSmall:
                        GeometryReader { screen in
                            
                            let width = screen.size.width / 2
                            
                            VStack {
                                
                                Text("Hey, how are you feeling today?")
                                    .font(.caption.bold())
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(currentTheme.hightlightColor)
                                
                                ZStack{
                                    Circle()
                                        .fill(currentTheme.text.opacity(0.1))
                                        .frame(width: width, height: width)
                                    
                                    Image(systemName: "plus")
                                        .font(.title.bold())
                                        .foregroundColor(currentTheme.hightlightColor)
                                }
                            }
                            .frame(width: screen.size.width, height: screen.size.height)
                            
                        }
                        .hasProBlurry(state)
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
               
            }.widgetURL(URL(string:  !entry.hasUnlockedPro ? "ProProthese://getPro" : "ProProthese://addFeeling"))
            
        }
       
    }
}

struct ProProtheseWidgetFeeling: Widget {
    let kind: String = "ProProtheseWidgetFeeling"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FeelingProvider(unlocked: AppTrailManager.hasProOrFreeTrail)) { entry in
            ProProtheseWidgetFeelingEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("How are you doing?")
        .description("Enter it quickly how the prosthesis is doing today.")
    }
}

struct ProProtheseWidgetFeeling_Previews: PreviewProvider {
    static var previews: some View {
        ProProtheseWidgetFeelingEntryView(entry: FeelingSimpleEntry(date: Date(), hasUnlockedPro: true))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
