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

    let url = URL(string: "ProProthese://pain")
    
    var workoutManager: WorkoutManager
    
    var entrySteps: Double
    
    var entryError: Error?
    
    var nextUpdate: Date {
        return Calendar.current.date(byAdding: .minute, value: 10, to: Date())!
    }

    var dummySteps: (min: Int, max: Int, current: Int, error: Error?) {
        return (min: 0, max: AppConfig.shared.targetSteps, current: 4567, error: nil)
    }
    
    func placeholder(in context: Context) -> SimpleEntry {        
        return SimpleEntry(date: Date(), nextUpdate: nextUpdate, url: self.url!, steps: dummySteps)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), nextUpdate: nextUpdate, url: self.url!, steps: dummySteps)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        
        let update = Calendar.current.date(byAdding: .minute, value: 10, to: currentDate)!

        let s = (min: 0, max: AppConfig.shared.targetSteps, current: Int(entrySteps), error: entryError)
        let entrie = SimpleEntry(date: Date(), nextUpdate: update, url: url, steps: s)
        
        let timeline = Timeline(entries: [entrie], policy: .after(update))
        completion(timeline)
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
        return Int(self.entry.steps.current) / AppConfig.shared.targetSteps * 100
    }
    
    private let debug = true
    
    var body: some View {
        let steps = entry.steps
        ZStack {
            switch widgetFamily {
            case .accessoryCircular:
                VStack(spacing: 1) {
                    
                    let gradient = Gradient(colors: [.white.opacity(0.5), AppConfig.shared.background])
                    
                    Gauge(value: Double(entry.steps.current), in: 0...Double(AppConfig.shared.targetSteps)) {
                        Text("\(entry.steps.current)")
                            .font(.system(size: 6))
                    } currentValueLabel: {
                        Text("🦿")
                    }
                    .gaugeStyle(.accessoryCircular)
                    .tint(gradient)
                    
                }
            case .accessoryCorner:
                Text("🦿")
                    .font(.system(size: 35))
                    .widgetLabel(label: {
                        Gauge(value: Double(entry.steps.current), in: 0...Double(AppConfig.shared.targetSteps)) {
                            Label("Speed", systemImage: "gauge")
                                .font(.system(size: 6))
                        } currentValueLabel: {
                            Text("\(steps.current)")
                        } minimumValueLabel: {
                            Text(String(format: "%.0f", steps.min))
                                .font(.system(size: 6))
                                .foregroundColor(.white.opacity(0.5))
                        } maximumValueLabel: {
                            Text(String(format: "%.0f", Double(AppConfig.shared.targetSteps) / 1000) + "k")
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .tint(steps.current > 100 ? AppConfig.shared.gaugeGradientBad : AppConfig.shared.gaugeGradientGood)
                        .labelStyle(.automatic)
                    })
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
                                Text("\(entry.steps.current)")
                                    .font(.system(size: 20).bold())
                                
                                let (_, targetPercent) = checkTargetSteps(steps: Double(entry.steps.current))
                                
                                Text("\( targetPercent )% vom Ziel")
                                    .font(.system(size: 12))
                            }
                        }
                        
                        Gauge(value: Double(entry.steps.current), in: 0...Double(AppConfig.shared.targetSteps)) {
                            Label("Speed", systemImage: "gauge")
                        } currentValueLabel: {
                          Text("\(entry.steps.current)")
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
                        
                        Text("\(entry.steps.current)")
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
    
    func checkTargetSteps(steps: Double) -> (Bool, Int) {
        let percent = steps / Double(AppConfig.shared.targetSteps) * 100
        let bool = percent >= 100 ? true : false
        return (bool, Int(percent))
    }
}

@main
struct ProProtheseWatchComplication: Widget {
    let kind: String = "ProProtheseWatchComplication"
    
    private var supportedFamilies:[WidgetFamily] = [
        .accessoryCircular,
        .accessoryCorner,
        .accessoryRectangular,
        .accessoryInline
    ]
    
    let hm = WorkoutManager()
    
    @AppStorage("Entry steps") var entrySteps: Double = 0
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(workoutManager: hm, entrySteps: entrySteps, entryError: nil)) { entry in
            ProProtheseWatchComplicationEntryView(entry: entry)
                .onAppear{
                    hm.queryWidgetSteps(completion: { stepCount, error in
                        if error?._code == 6 {
                            
                        } else {
                            self.entrySteps = stepCount
                        }
                    })
                }
                .onChange(of: entry.date){ newDate in
                    hm.queryWidgetSteps(completion: { stepCount, error in
                        
                        if error?._code == 6 {
                            
                        } else {
                            self.entrySteps = stepCount
                        }
                        
                    })
                }
        }
        .supportedFamilies(supportedFamilies)
        .configurationDisplayName("Schritte heute")
        .description("This is an example widget.")
    }
}

struct ProProtheseWatchComplication_Previews: PreviewProvider {
    static var nextUpdate: Date {
        return Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
    }

    static var dummySteps: (min: Int, max: Int, current: Int, error: Error?) {
        return (min: 0, max: AppConfig.shared.targetSteps, current: 4567, error: nil)
    }
    
    static var supportedFamilies:[(widget: WidgetFamily, name: String)] = [
        (widget: .accessoryCircular, name: "Circular"),
        (widget: .accessoryCorner, name: "Corner"),
        (widget: .accessoryRectangular, name: "Regangular"),
        (widget: .accessoryInline, name: "Inline")
    ]
    
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
}
