//
//  StopWatchComplication.swift
//  StopWatchComplication
//
//  Created by Frederik Kohler on 15.06.23.
//

import WidgetKit
import SwiftUI
import HealthKit

struct Provider: TimelineProvider {

    let url = URL(string: "ProProthese://stopWatch")
    
    var workoutManager: WorkoutManager
    
    var nextUpdate: Date {
        return Calendar.current.date(byAdding: .minute, value: 10, to: Date())!
    }

    var dummySteps: (min: Int, max: Int, current: Int, error: Error?) {
        return (min: 0, max: AppConfig.shared.targetSteps, current: 4567, error: nil)
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), nextUpdate: nextUpdate, url: self.url!, steps: dummySteps, isRunning: false, timer: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), nextUpdate: nextUpdate, url: self.url!, steps: dummySteps, isRunning: false, timer: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        
        let startDate = Calendar.current.startOfDay(for: currentDate)

        workoutManager.queryWidgetSteps(completion: { stepCount, error in
            
            let s = (min: 0, max: AppConfig.shared.targetSteps, current: Int(stepCount), error: error)
            let entrie = SimpleEntry(date: Date(), nextUpdate: nextUpdate, url: url, steps: s, isRunning: false, timer: Date())
            
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
    let isRunning: Bool
    let timer: Date
}

struct StopWatchComplicationEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    
    private var percentSteps: Int {
        return Int(self.entry.steps.current) / 10000 * 100
    }
    
    var body: some View {
        let steps = entry.steps
        ZStack {
            switch widgetFamily {
            case .accessoryCircular:
                Circular(steps: steps)
            case .accessoryCorner:
                Corner(steps: steps)
            case .accessoryRectangular:
                Rectangular(steps: steps)
            case .accessoryInline:
                Inline(steps: steps)
            @unknown default:
                VStack {
                    Text("default")
                    Text(entry.date, format: .dateTime)
                }
            }
        }
        .widgetURL(entry.url)
    }
    
    @ViewBuilder
    func Circular(steps: (min: Int, max: Int, current: Int, error: (any Error)?)) -> some View{
        VStack(spacing: 1) {
            
            let gradient = Gradient(colors: [.white.opacity(0.5), AppConfig.shared.background])
            
            Gauge(value: Double(entry.steps.current), in: 0...Double(AppConfig.shared.targetSteps)) {
                Image( systemName: entry.isRunning ? "stop.fill" : "record.circle" )
            } currentValueLabel: {
                if entry.isRunning {
                    Text(entry.date, style: .timer)
                        .padding(2)
                } else {
                    Text("🦿")
                }
            }
            .gaugeStyle(.accessoryCircular)
            .tint(gradient)
            
        }
    }
    
    @ViewBuilder
    func Corner(steps: (min: Int, max: Int, current: Int, error: (any Error)?)) -> some View {
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
    }
    
    @ViewBuilder
    func Rectangular(steps: (min: Int, max: Int, current: Int, error: (any Error)?)) -> some View {
        ZStack {
            VStack(alignment: .leading, spacing: 5) {

                HStack {
                    
                    if !entry.isRunning {
                        HStack(alignment: .center) {
                            Text("🦿")
                            
                            Text("0:00")
                                .font(.system(size: 20).bold())
                            
                            Spacer()
                            
                            Text("Start".uppercased())
                                .font(.system(size: 20).bold())
                                .foregroundColor(.yellow)
                                .padding(.trailing, 10)
                        }
                    } else {
                        HStack(alignment: .center) {
                            Text("🦿")
                            
                            Text(entry.timer , style: .timer)
                                .font(.system(size: 20).bold())
                            
                            Spacer()
                            
                            Text("Stop".uppercased())
                                .font(.system(size: 20).bold())
                                .foregroundColor(.yellow)
                                .padding(.trailing, 10)
                        }
                    }
                    
                }
                
                HStack {
                    
                    VStack {
                        
                        let gradient = Gradient(colors: [.white.opacity(0.5), AppConfig.shared.background])
                        
                        Gauge(value: Double(entry.steps.current), in: 0...Double(AppConfig.shared.targetSteps)) {
                        } currentValueLabel: {
                            
                        }
                        .gaugeStyle(.accessoryLinear)
                        .tint(gradient)
                       
                        HStack {
                            Text("\(Int(steps.current)) Schritte")
                                .font(.system(size: 10).bold())
                                .padding(.leading, 5)
                            
                            Spacer()
                            
                            Text("Update: " + entry.date.formatteTime(time: "HH:mm")).font(.system(size: 10).bold())
                                .padding(.trailing, 5)
                        }
                        
                    }
                }
                
            }
            .cornerRadius(10)
            .padding()
            .cornerRadius(10)
        }.widgetURL(entry.url)
    }
    
    @ViewBuilder
    func Inline(steps: (min: Int, max: Int, current: Int, error: (any Error)?)) -> some View {
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
    }
}

@main
struct StopWatchComplication: Widget {
    let kind: String = "StopWatchComplication"
    
    let hm = WorkoutManager()
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(workoutManager: hm)) { entry in
            StopWatchComplicationEntryView(entry: entry)
        }
        .configurationDisplayName("Prothesen Timer")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular])
        .description("Starte und Beende deine Prothesenzeiten schnell.")
    }
}

struct StopWatchComplication_Previews: PreviewProvider {
    static var nextUpdate: Date {
        return Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
    }

    static var dummySteps: (min: Int, max: Int, current: Int, error: Error?) {
        return (min: 0, max: AppConfig.shared.targetSteps, current: 4567, error: nil)
    }
    
    static var supportedFamilies:[(widget: WidgetFamily, name: String)] = [
        (widget: .accessoryCircular, name: "Circular"),
        (widget: .accessoryRectangular, name: "Regangular"),
        (widget: .accessoryInline, name: "Inline")
    ]
    
    static var previews: some View {
        let url = URL(string: "ProProthese://pain")
        let entry = SimpleEntry(date: Date(), nextUpdate: nextUpdate, url: url!, steps: dummySteps, isRunning: true, timer: Date())
        Group {
           
            ForEach(supportedFamilies, id:\.0) { item in
                StopWatchComplicationEntryView(
                    entry: entry
                )
                .previewContext(WidgetPreviewContext(family: item.widget))
                .previewDisplayName("\(item.name)")
            }
        }
    }
}
extension Date {
    func formatteTime(time: String) -> String {
        let formattedTime = DateFormatter()
        formattedTime.dateFormat = time
        return formattedTime.string(from: self)
    }
}
