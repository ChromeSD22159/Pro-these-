//
//  ProProtheseWidget.swift
//  ProProtheseWidget
//
//  Created by Frederik Kohler on 13.06.23.
//

import WidgetKit
import SwiftUI
import Foundation

struct TodayStepsProvider: TimelineProvider {
    let url = URL(string: "ProProthese://feeling")
    
    var nextUpdate: Date {
        return Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
    }

    var dummySteps: (min: Int, max: Int, current: Int, error: Error?) {
        return (min: 0, max: AppConfig.shared.targetSteps, current: 4567, error: nil)
    }
    
    func placeholder(in context: Context) -> TodayStepsSimpleEntry {
        TodayStepsSimpleEntry(date: Date(), nextUpdate: Date(), url: url, steps: dummySteps)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayStepsSimpleEntry) -> ()) {
        let entry = TodayStepsSimpleEntry(date: Date(), nextUpdate: Date(), url: url, steps: dummySteps)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        HealthStoreProvider().queryWidgetSteps(completion: { stepCount, error in
            
            let s = (min: 0, max: AppConfig.shared.targetSteps, current: Int(stepCount), error: error)
            let entrie = TodayStepsSimpleEntry(date: Date(), nextUpdate: nextUpdate, url: url, steps: s)
            
            let timeline = Timeline(entries: [entrie], policy: .after(nextUpdate))
            completion(timeline)
            
        })

        
    }
}

struct TodayStepsSimpleEntry: TimelineEntry {
    let date: Date
    let nextUpdate: Date
    let url: URL?
    let steps: (min: Int , max: Int , current: Int, error: Error?)
}

struct ProProtheseWidgetTodayStepsEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: TodayStepsProvider.Entry
    
    private let debug = true
    
    var body: some View {
        ZStack {
            Link(destination: entry.url!) {
                
                LinearGradient(colors: [Color(red: 32/255, green: 40/255, blue: 63/255), Color(red: 4/255, green: 5/255, blue: 8/255)], startPoint: .top, endPoint: .bottom)
                
                switch widgetFamily {
                case .systemSmall:
                    GeometryReader { screen in
                        
                        VStack {
                            
                            Spacer()
                            
                            if (entry.steps.error != nil) {
                                
                                Text("Widget konnte keine Schritte laden")
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundColor(.gray)
                                
                                if debug {
                                    Text(entry.steps.error!.localizedDescription)
                                        .font(.system(size: 8, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                                
                            } else {
                             
                                Gauge(value: Double(entry.steps.current), in: 0...Double(AppConfig.shared.targetSteps)) {
                                    Text("")
                                } currentValueLabel: {
                                    Image("prothesis")
                                        .imageScale(.large)
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                }
                                .gaugeStyle(.accessoryCircularCapacity)
                                .tint(.yellow)
                                
                                Text("\(entry.steps.current)")
                                    .font(.body.bold())
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                
                                Text("Heute")
                                    .font(.caption.bold())
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                HStack(alignment: .center){
                                    Text("Nächtes Update: \(entry.nextUpdate.dateFormatte(date: "", time: "HH:mm").time)")
                                        .font(.system(size: 8, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                                .frame(alignment: .center)
                                .padding(.trailing, 10)
                                .padding(.bottom, 5)
                                
                            }
                        }
                        .frame(width: screen.size.width, height: screen.size.height)
                        .widgetURL(entry.url)
                        
                    }
                case .systemLarge:
                    VStack {
                        Text(entry.date, style: .time)
                        Text("Large Widget")
                    }
                    
                case .accessoryCircular:
                    ZStack {
                        AccessoryWidgetBackground().opacity(0)
                        
                        ViewThatFits{
                            VStack {
                                Gauge(value: Double(entry.steps.current), in: 0...Double(AppConfig.shared.targetSteps)) {
                                    
                                } currentValueLabel: {
                                    Image("prothesis")
                                        .imageScale(.large)
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                }
                                .gaugeStyle(.accessoryCircularCapacity)
                                .widgetAccentable()
                            }
                        }
                    }.widgetURL(entry.url)
                case .accessoryRectangular:
                    ZStack {
                        AccessoryWidgetBackground().opacity(0)
                        
                        ViewThatFits {
                            HStack {
                                VStack {
                                    Image("prothesis")
                                        .imageScale(.large)
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("\(entry.steps.current)")
                                        .font(.body.bold())
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.white)
                                    
                                    Text("\(entry.date.convertDateToDayNames()). \(entry.date.dateFormatte(date: "dd.MM", time: "").date)")
                                        .font(.caption2.bold())
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }.widgetURL(entry.url)
                case .accessoryInline:
                    ZStack {
                        AccessoryWidgetBackground().opacity(0)
                            
                        ViewThatFits {
                            HStack{
                                Image("prothesis")
                                    .imageScale(.large)
                                    .font(.system(size: 30))
                                
                                Text("\(entry.steps.current) Schritte")
                            }
                        }
                    }.widgetURL(entry.url)
                default:
                    VStack {
                        Text(entry.date, style: .time)
                            .font(.caption.bold())
                        Text("Default")
                    }
                }
            }
        }
    }
}

struct ProProtheseWidgetTodaySteps: Widget {
    let kind: String = "ProProtheseWidgetTodaySteps"
    
    private var supportedFamilies:[WidgetFamily] = [
        .systemSmall,
        .accessoryCircular,
        .accessoryRectangular,
        .accessoryInline
    ]
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayStepsProvider()) { entry in
            ProProtheseWidgetTodayStepsEntryView(entry: entry)
                .onAppear(perform: {
                    print(entry.steps.error)
                })
        }
        .supportedFamilies(supportedFamilies)
        .configurationDisplayName("Schritte Heute")
        .description("Sehe überall dein täglichen Fortschritt")
      
    }
}

struct ProProtheseWidgetTodaySteps_Previews: PreviewProvider {
    static var supportedFamilies:[(widget: WidgetFamily, name: String)] = [
        (widget: .systemSmall, name: "Small"),
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
                ProProtheseWidgetTodayStepsEntryView(
                    entry: TodayStepsSimpleEntry(
                        date: Date(),
                        nextUpdate: Calendar.current.date(byAdding: .minute, value: 10, to: Date())!,
                        url: URL(string: "ProProthese://feeling"),
                        steps: dummySteps
                    )
                )
                .previewContext(WidgetPreviewContext(family: item.widget))
                .previewDisplayName("\(item.name)")
            }
 
        }
    }
}
