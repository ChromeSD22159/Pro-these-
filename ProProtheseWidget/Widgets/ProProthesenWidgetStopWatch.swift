//
//  ProProtheseWidget.swift
//  ProProtheseWidget
//
//  Created by Frederik Kohler on 13.06.23.
//

import WidgetKit
import SwiftUI

struct StopWatchProvider: TimelineProvider {
    var unlock: Bool
    
    func placeholder(in context: Context) -> StopWatchSimpleEntry {
        StopWatchSimpleEntry(date: Date(), hasUnlockedPro: unlock)
    }

    func getSnapshot(in context: Context, completion: @escaping (StopWatchSimpleEntry) -> ()) {
        let entry = StopWatchSimpleEntry(date: Date(), hasUnlockedPro: unlock)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [StopWatchSimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = StopWatchSimpleEntry(date: entryDate, hasUnlockedPro: unlock)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct StopWatchSimpleEntry: TimelineEntry {
    let date: Date
    let hasUnlockedPro: Bool
}

struct ProProthesenWidgetStopWatchEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    
    private var currentTheme: Theme {
        return ThemeManager().currentTheme()
    }
    
    var entry: StopWatchProvider.Entry
    
    @ObservedObject var appConfig = AppConfig()
     
    var body: some View {
        
        Link(destination: URL(string: entry.hasUnlockedPro ? appConfig.recorderState ? "ProProthese://stopWatchStop" : "ProProthese://stopWatchStart" : "ProProthese://getPro")!) {
            ZStack {
                
                currentTheme.gradientBackground(nil)
                
                hasProFeatureOverlay(binding: !entry.hasUnlockedPro, label: true) { state in
                    GeometryReader { screen in
                        
                        let width = screen.size.width / 2
                        
                        VStack {
                            
                            Text("Check your prosthesis timer.")
                                .font(.caption.bold())
                                .multilineTextAlignment(.center)
                                .foregroundColor(currentTheme.hightlightColor)
                            
                            Spacer()
                            
                            if appConfig.recorderState {
                                HStack {
                                    Text(appConfig.recorderTimer, style: .timer)
                                        .font(.subheadline.bold())
                                        .foregroundColor(currentTheme.hightlightColor)
                                        .multilineTextAlignment(.center)
                                    
                                    ZStack{
                                        Circle()
                                            .fill(currentTheme.text.opacity(0.1))
                                            .frame(width: width / 2, height: width / 2)
                                        
                                        Image(systemName: appConfig.recorderState ? "stop.fill" : "play.fill")
                                            .font(.title3.bold())
                                            .foregroundColor(currentTheme.hightlightColor)
                                    }
                                }
                                .padding(10)
                                .font(.caption2)
                            } else {
                                HStack {
                                    Spacer()
                                    ZStack{
                                        Circle()
                                            .fill(currentTheme.text.opacity(0.1))
                                            .frame(width: width, height: width)
                                        
                                        Image(systemName: appConfig.recorderState ? "stop.fill" : "play.fill")
                                            .font(.title3.bold())
                                            .foregroundColor(currentTheme.hightlightColor)
                                    }
                                    Spacer()
                                }
                                .font(.caption2)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .frame(width: screen.size.width, height: screen.size.height)
                        .hasProBlurry(state)
                        
                    }
                }
            }
            .widgetURL(URL(string: entry.hasUnlockedPro ? appConfig.recorderState ? "ProProthese://stopWatchStop" : "ProProthese://stopWatchStart" : "ProProthese://getPro"))
        }
    }
}

struct ProProthesenWidgetStopWatch: Widget {
    let kind: String = "ProProthesenWidgetStopWatch"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StopWatchProvider(unlock: AppTrailManager.hasProOrFreeTrail)) { entry in
            ProProthesenWidgetStopWatchEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("Prosthesis wearing times")
        .description("Stop wearing your prostheses.")
    }
}

struct ProProthesenWidgetStopWatch_Previews: PreviewProvider {
    static var previews: some View {
        ProProthesenWidgetStopWatchEntryView(entry: StopWatchSimpleEntry(date: Date(), hasUnlockedPro: true))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
