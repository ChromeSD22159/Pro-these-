//
//  ProProtheseWatchComplication.swift
//  ProProtheseWatchComplication
//
//  Created by Frederik Kohler on 14.06.23.
//

import WidgetKit
import SwiftUI
import ClockKit
import HealthKit

struct Provider: TimelineProvider {

    var nextUpdate: Date {
        return Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
    }

    let url = URL(string: "ProProthese://pain")

    var dummySteps: (min: Int, max: Int, current: Int, error: Error?) {
        return (min: 0, max: AppConfig.shared.targetSteps, current: 4567, error: nil)
    }
    
    func placeholder(in context: Context) -> SimpleEntry {        
        return SimpleEntry(date: Date(), nextUpdate: Date(), url: url, steps: dummySteps)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry(date: Date(), nextUpdate: Date(), url: url, steps: dummySteps))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        WorkoutManager().queryWidgetSteps(completion: { stepCount, error in
            
            let s = (min: 0, max: AppConfig.shared.targetSteps, current: Int(stepCount), error: error)
            let entrie = SimpleEntry(date: Date(), nextUpdate: nextUpdate, url: url, steps: s)
            
            let timeline = Timeline(entries: [entrie], policy: .after(nextUpdate))
            completion(timeline)
            
        })
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let nextUpdate: Date
    let url: URL?
    let steps: (min: Int , max: Int , current: Int, error: Error?)
}

struct ProProtheseWatchComplicationEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    
    private var percentSteps: Int {
        return Int(self.entry.steps.current) / 10000 * 100
    }
    
    private let debug = true
    
    var body: some View {
        let steps = entry.steps
        ZStack {
            switch widgetFamily {
            case .accessoryCircular:
                ZStack {
                    
                    VStack(spacing: 2) {
                        
                        Image("prothesis")
                            .imageScale(.large)
                            .font(.title)
                            .foregroundColor(.white)
                        
                        Text(String(format: "%.0f", steps.current))
                            .font(.system(size: 10).bold())
                    }
                }
            case .accessoryCorner:
                ZStack {
                    
                    Image("prothesis")
                        .imageScale(.large)
                        .font(.system(size: 30))
                        .widgetLabel {
                            Gauge(value: Double(entry.steps.current), in: 0...Double(AppConfig.shared.targetSteps)) {
                                Label("Speed", systemImage: "gauge")
                            } currentValueLabel: {
                              Text("\(steps.current)")
                            } minimumValueLabel: {
                                Text(String(format: "%.0f", steps.min))
                                    .font(.system(size: 6))
                                    .foregroundColor(.white.opacity(0.5))
                            } maximumValueLabel: {
                                Text(String(format: "%.0f", steps.max))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .tint(steps.current > 100 ? AppConfig.shared.gaugeGradientBad : AppConfig.shared.gaugeGradientGood)
                            .labelStyle(.automatic)
                        }
                }
            case .accessoryRectangular:
                ZStack {
                    
                    VStack(alignment: .leading, spacing: 5) {
                        
                        HStack {
                            Image("prothesis")
                                .imageScale(.large)
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .padding(.trailing, 10)
                            
                            VStack(alignment: .leading) {
                                Text(String(format: "%.0f", steps.current))
                                    .font(.system(size: 20).bold())
                                
                             
                                
                                Text("100% vom Ziel")
                                    .font(.system(size: 12))
                            }
                        }
                        
                        Gauge(value: Double(entry.steps.current), in: 0...Double(AppConfig.shared.targetSteps)) {
                            Label("Speed", systemImage: "gauge")
                        } currentValueLabel: {
                          Text("\(steps.current)")
                        } minimumValueLabel: {
                          Image(systemName: "gauge.low")
                                .foregroundColor(.white.opacity(0.5))
                        } maximumValueLabel: {
                          Image(systemName: "gauge.high")
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .tint(steps.current > 100 ? AppConfig.shared.gaugeGradientBad : AppConfig.shared.gaugeGradientGood)
                        .labelStyle(.iconOnly)
                        
                    }
                    .cornerRadius(10)
                    .padding()
                    .cornerRadius(10)
                }
            case .accessoryInline:
                ZStack {
                    
                    VStack(spacing: 2) {
                        
                        Text(String(format: "%.0f", steps.current))
                            .font(.system(size: 10).bold())
                            .widgetLabel{
                                Image("prothesis")
                                    .imageScale(.large)
                                    .font(.system(size: 30))
                            }
                       
                    }
                }
            @unknown default:
                VStack {
                    Text("default")
                    Text(entry.date, format: .dateTime)
                }
            }
        }
        .widgetURL(URL(string: "ProProthese://stopWatch"))
    }
}

@main
struct ProProtheseWatchComplication: Widget {
    let kind: String = "ProProtheseWatchComplication"
    
    private var supportedFamilies:[WidgetFamily] = [
        .accessoryCircular,
        .accessoryRectangular,
        .accessoryInline
    ]
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ProProtheseWatchComplicationEntryView(entry: entry)
        }
        .supportedFamilies(supportedFamilies)
        .configurationDisplayName("Schritte heute")
        .description("This is an example widget.")
    }
}

struct ProProtheseWatchComplication_Previews: PreviewProvider {
    static var supportedFamilies:[(widget: WidgetFamily, name: String)] = [
        (widget: .accessoryCircular, name: "Circular"),
        (widget: .accessoryRectangular, name: "Regangular"),
        (widget: .accessoryInline, name: "Inline")
    ]
    
    static var dummySteps: (min: Int, max: Int, current: Int, error: Error?) {
        return (min: 0, max: AppConfig.shared.targetSteps, current: 4567, error: nil)
    }
    
    static var previews: some View {

        Group {
            
            ForEach(supportedFamilies, id:\.0) { item in
                ProProtheseWatchComplicationEntryView(
                    entry:  SimpleEntry(
                        date: Date(),
                        nextUpdate: Date(),
                        url: URL(string: "ProProthese://pain"),
                        steps: dummySteps
                    )
                )
                .previewContext(WidgetPreviewContext(family: item.widget))
                .previewDisplayName("\(item.name)")
            }
 
        }
    }
}

extension Date {
    func formatte(date: String? = nil, time: String? = nil) -> (date:String?, time:String?) {
        let formattedDate = DateFormatter()
        formattedDate.dateFormat = date
        
        let formattedTime = DateFormatter()
        formattedTime.dateFormat = time
        return (date: formattedDate.string(from: self), time: formattedTime.string(from: self))
    }

    func endOfDay(_ date: Date) -> Date {
        var components = DateComponents()
            components.day = 1
            components.second = -1
            return Calendar.current.date(byAdding: components, to: date)!
    }
}
