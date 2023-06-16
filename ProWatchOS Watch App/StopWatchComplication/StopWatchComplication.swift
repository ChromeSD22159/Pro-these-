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
    
    @State var currentSteps = 1.0
    
    var workoutManager: WorkoutManager
    
    func placeholder(in context: Context) -> SimpleEntry {
        
        let steps = (min: 0.0, max: Double(AppConfig.shared.targetSteps), current: currentSteps)
        
        return SimpleEntry(date: Date(), url: self.url!, steps: steps, isRunning: false, timer: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let steps = (min: 0.0, max: Double(AppConfig.shared.targetSteps), current: currentSteps)
        let entry = SimpleEntry(date: Date(), url: self.url!, steps: steps, isRunning: false, timer: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        
        var entries:[SimpleEntry] = []
        
        let startDate = Calendar.current.startOfDay(for: currentDate)

        workoutManager.retrieveStepCount(today: startDate) { (steps, error) in
            let steps = (min: 0.0, max: Double(AppConfig.shared.targetSteps), current: steps ?? 1234)
            let entry = SimpleEntry(date: currentDate, url: url!, steps: steps, isRunning: false, timer: Date())
            entries.append(entry)
        }
        
        if entries.count == 0 {
            let steps = (min: 0.0, max: Double(AppConfig.shared.targetSteps), current: 99999.5)
            let entry = SimpleEntry(date: currentDate, url: url!, steps: steps, isRunning: false, timer: Date())
            entries.append(entry)
        }
        
        let refreshDate = Calendar.current.date(byAdding: .second, value: 10, to: currentDate)!
        
        let timeline = Timeline(entries: entries, policy: .after(refreshDate))
        completion(timeline)
    }

}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let url: URL
    let steps: (min: Double, max: Double, current: Double)
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
    func Circular(steps: (min: Double, max: Double, current: Double)) -> some View{
        VStack(spacing: 1) {
            
            let gradient = Gradient(colors: [.white.opacity(0.5), AppConfig.shared.background])
            
            Gauge(value: steps.current, in: steps.min...steps.max) {
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
    func Corner(steps: (min: Double, max: Double, current: Double)) -> some View {
        ZStack {
            
            Image("prothesis")
                .imageScale(.large)
                .font(.system(size: 30))
                .widgetLabel {
                    Gauge(value: steps.current, in: steps.min...steps.max) {
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
    func Rectangular(steps: (min: Double, max: Double, current: Double)) -> some View {
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
                    //Image(systemName: "figure.walk")
                    
                    VStack {
                        /*Gauge(value: 25, in: 0...100) {
                            
                        }
                        .gaugeStyle(.accessoryLinearCapacity)
                        .tint(gradient)*/
      
                        let gradient = Gradient(colors: [.white.opacity(0.5), AppConfig.shared.background])
                        
                        Gauge(value: steps.current, in: steps.min...steps.max) {
                        } currentValueLabel: {
                            
                        }
                        .gaugeStyle(.accessoryLinear)
                        .tint(gradient)
                       
                        HStack {
                            Text("\(Int(steps.current)) Schritte heute")
                                .font(.system(size: 10).bold())
                            
                            Spacer()
                            
                            Text(entry.date.formatteTime(time: "HH:mm:ss")).font(.system(size: 10).bold())
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
    func Inline(steps: (min: Double, max: Double, current: Double)) -> some View {
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
    static var previews: some View {
        let url = URL(string: "ProProthese://pain")
        let entry = SimpleEntry(date: Date(), url: url!, steps: (min: 0.0, max: 10000.0, current: 3594.0), isRunning: true, timer: Date())
        Group {
            StopWatchComplicationEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("accessoryCircular")
            
            StopWatchComplicationEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .accessoryCorner))
                .previewDisplayName("accessoryCorner")
            
            StopWatchComplicationEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("accessoryRectangular")
            
            StopWatchComplicationEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
                .previewDisplayName("accessoryInline")
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
