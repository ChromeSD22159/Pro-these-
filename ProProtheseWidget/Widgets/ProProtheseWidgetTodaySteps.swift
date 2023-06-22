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
    let urlEntry = URL(string: "ProProthese://statistic")
    
    @AppStorage("Entry steps") var entrySteps: Int = -10
    
    var unlocked: Bool
    
    var nextUpdate: Date {
        return Calendar.current.date(byAdding: .minute, value: 5 , to: Date())!
    }

    var dummySteps: (min: Int, max: Int, current: Int, error: Error?) {
        return (min: 0, max: AppConfig.shared.targetSteps, current: 4567, error: nil)
    }
    
    func placeholder(in context: Context) -> TodayStepsSimpleEntry {
        TodayStepsSimpleEntry(date: Date(), nextUpdate: nextUpdate, url: urlEntry, steps: dummySteps, hasUnlockedPro: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayStepsSimpleEntry) -> ()) {
        let entry = TodayStepsSimpleEntry(date: Date(), nextUpdate: nextUpdate, url: urlEntry, steps: dummySteps, hasUnlockedPro: true)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries:[TodayStepsSimpleEntry] = []
        var entryDate = Date()
        
        if unlocked {
            entryDate = Calendar.current.date(byAdding: .minute, value: 5 , to: Date())!
            
            let s:(min: Int, max: Int, current: Int, error: Error?) = (min: 0, max: AppConfig.shared.targetSteps, current: 0, error: nil)
            let entrie = TodayStepsSimpleEntry(date: Date(), nextUpdate: entryDate, url: URL(string: "ProProthese://statistic"), steps: s, hasUnlockedPro: unlocked)

            entries.append(entrie)
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            
            completion(timeline)
        } else {
            entryDate = Calendar.current.date(byAdding: .minute, value: 5 , to: Date())!
            
            let s:(min: Int, max: Int, current: Int, error: Error?) = (min: 0, max: AppConfig.shared.targetSteps, current: 0, error: nil)
            let entrie = TodayStepsSimpleEntry(date: Date(), nextUpdate: entryDate, url: URL(string: "ProProthese://unlock"), steps: s, hasUnlockedPro: unlocked)

            entries.append(entrie)
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            
            completion(timeline)
        }
        
        
        
    }
}

struct TodayStepsSimpleEntry: TimelineEntry {
    let date: Date
    let nextUpdate: Date
    let url: URL?
    let steps: (min: Int , max: Int , current: Int, error: Error?)
    let hasUnlockedPro: Bool
}

struct ProProtheseWidgetTodayStepsEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: TodayStepsProvider.Entry
    
    private let debug = true
    
    @AppStorage("Entry Date") var entryDate: String = ""
    @AppStorage("Entry steps") var entrySteps: Int = 123
    @State var entryError: Error?
    
    var body: some View {
        ZStack {
            Link(destination: entry.url!) {
                
                LinearGradient(colors: [Color(red: 32/255, green: 40/255, blue: 63/255), Color(red: 4/255, green: 5/255, blue: 8/255)], startPoint: .top, endPoint: .bottom)
                
                switch widgetFamily {
                case .systemSmall:
                    GeometryReader { screen in
                        
                        VStack {
                            
                            Spacer()
                            
                            Gauge(value: Double(entrySteps), in: 0...Double(AppConfig.shared.targetSteps)) {
                                Text("")
                            } currentValueLabel: {
                                Image("prothesis")
                                    .imageScale(.large)
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            }
                            .gaugeStyle(.accessoryCircularCapacity)
                            .tint(.yellow)
                            
                            Spacer()
                            
                            HStack(alignment: .center){
                                Text("Schritte heute")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .frame(alignment: .center)
                            .padding(.trailing, 10)
                            
                            Text("\(entrySteps)")
                                .font(.title.bold())
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)

                            HStack(alignment: .center){
                                Text("Stand: \(entryDate)")
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                            .frame(alignment: .center)
                            .padding(.trailing, 10)
                            
                            Text(entry.steps.error?.localizedDescription ?? "")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(.gray)
                                .padding(.bottom, 5)
   
                        }
                        .frame(width: screen.size.width, height: screen.size.height)
                        .widgetURL(entry.url)
                        
                    }

                case .accessoryCircular:
                    ZStack {
                        
                        ViewThatFits{
                            VStack {
                                Gauge(value: Double(entrySteps), in: 0...Double(AppConfig.shared.targetSteps)) {
                                    
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
                        
                        hasProFeatureOverlay(binding: !entry.hasUnlockedPro) { state in
                            ViewThatFits {
                                HStack {
                                    VStack {
                                        Image("prothesis")
                                            .imageScale(.large)
                                            .font(.system(size: 30))
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text("\(entrySteps)")
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
                            .hasProBlurry(state)
                        }
  
                    }.widgetURL(entry.url)
                    
                case .accessoryInline:
                    ZStack {
                            
                        ViewThatFits {
                            HStack{
                                Image("prothesis")
                                    .imageScale(.large)
                                    .font(.system(size: 30))
                                
                                Text("\(entrySteps) Schritte")
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
        .onAppear(perform: {
            HealthStoreProvider().queryWidgetSteps(completion: { stepCount, error in
                if error?._code == 6 {
                    print("SA: \(self.entrySteps)")
                } else {
                    self.entrySteps = Int(stepCount)
                }
                self.entryError = error
                self.entryDate = Date().dateFormatte(date: "dd.MM.yyyy", time: "HH:mm").date + " " + Date().dateFormatte(date: "dd.MM.yyyy", time: "HH:mm").time
            })
        })
        .onChange(of: entry.date, perform: { newDate in
            HealthStoreProvider().queryWidgetSteps(completion: { stepCount, error in
                
                if error?._code == 6 {
                    print("SC: \(self.entrySteps)")
                } else {
                    self.entrySteps = Int(stepCount)
                }
                
                self.entryError = error
                self.entryDate = Date().dateFormatte(date: "dd.MM.yyyy", time: "HH:mm").date + " " + Date().dateFormatte(date: "dd.MM.yyyy", time: "HH:mm").time
            })
        })
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
    
    // FIX UNLOCK
    @AppStorage("unlocked") var unlocked: Bool = true
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayStepsProvider(unlocked: unlocked)) { entry in
            ProProtheseWidgetTodayStepsEntryView(entry: entry)
                .background(.clear)
                .cornerRadius(20)
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
                
                ProProtheseWidgetTodayStepsEntryView( entry: TodayStepsSimpleEntry(
                        date: Date(),
                        nextUpdate: Calendar.current.date(byAdding: .minute, value: 1 , to: Date())!,
                        url: URL(string: "ProProthese://statistic"),
                        steps: dummySteps,
                        hasUnlockedPro: false
                    )
                )
                .previewContext(WidgetPreviewContext(family: item.widget))
                .previewDisplayName("\(item.name)")
                .cornerRadius(20)
                
            }
 
        }
    }
}
