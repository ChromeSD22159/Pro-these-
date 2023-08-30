//
//  ProProtheseWidget.swift
//  ProProtheseWidget
//
//  Created by Frederik Kohler on 13.06.23.
//

import WidgetKit
import SwiftUI
import Foundation

struct TodayWorkoutsProvider: TimelineProvider {
    let urlEntry = URL(string: "ProProthese://statisticWorkout")
    let urlUnlock = URL(string: "ProProthese://unlock")
    
    var unlocked: Bool
    
    private let entryCache = EntryCache()
    
    var nextUpdate: Date {
        return Calendar.current.date(byAdding: .minute, value: 1 , to: Date())!
    }
    
    func placeholder(in context: Context) -> TodayWorkoutsSimpleEntry {
        TodayWorkoutsSimpleEntry(date: Date(), nextUpdate: Date(), url: urlEntry, hasUnlockedPro: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayWorkoutsSimpleEntry) -> ()) {
        let entry = TodayWorkoutsSimpleEntry(date: Date(), nextUpdate: Date(), url: urlEntry, hasUnlockedPro: true)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let url = unlocked ? urlEntry : urlUnlock
        
        let entrie = TodayWorkoutsSimpleEntry(date: Date(), nextUpdate: nextUpdate, url: url, hasUnlockedPro: unlocked)
        
        let timeline = Timeline(entries: [entrie], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct TodayWorkoutsSimpleEntry: TimelineEntry {
    let date: Date
    let nextUpdate: Date
    let url: URL?
    let hasUnlockedPro: Bool
}

struct ProProtheseWidgetTodayWorkoutsEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: TodayWorkoutsProvider.Entry

    private var currentTheme: Theme {
        return ThemeManager().currentTheme()
    }
    
    @AppStorage("Entry Date") var entryDate: String = ""
    @AppStorage("Entry steps") var entrySteps: Int = -10
    @AppStorage("Entry Workouts") var entryWorkouts:String = "0"
    
    var body: some View {
        ZStack {
            Link(destination: entry.url!) {
                
                currentTheme.gradientBackground(nil)
                
                switch widgetFamily {
                case .systemSmall:
                    GeometryReader { screen in
                        
                        VStack {
                            
                            Spacer()
                            
                            Gauge(value: Double(entrySteps), in: 0...Double(AppConfig.shared.targetSteps)) {
                                Text("")
                            } currentValueLabel: {
                                Image("figure.prothese")
                                    .imageScale(.large)
                                    .font(.system(size: 25))
                                    .foregroundStyle(currentTheme.text, currentTheme.textGray)
                            }
                            .gaugeStyle(.accessoryCircularCapacity)
                            .tint(currentTheme.hightlightColor)
                            
                            Spacer()
                            
                            HStack(alignment: .center){
                                Text("Prosthesis time today")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(currentTheme.text)
                            }
                            .frame(alignment: .center)
                            .padding(.trailing, 10)
                            
                            Text("\(entryWorkouts)")
                                .font(.title.bold())
                                .multilineTextAlignment(.center)
                                .foregroundColor(currentTheme.hightlightColor)
                            
                            HStack(alignment: .center){
                                Text("Time: \(entryDate)")
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundColor(currentTheme.textGray)
                            }
                            .frame(alignment: .center)
                            .padding(.trailing, 10)
                            
                            Text("")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(currentTheme.textGray)
                                .padding(.bottom, 5)
   
                        }
                        .frame(width: screen.size.width, height: screen.size.height)
                        .widgetURL(entry.url)
                        
                    }
                case .accessoryCircular:
                    ZStack {
                        
                        hasProFeatureOverlay(binding: !entry.hasUnlockedPro) { state in
                            
                            ViewThatFits{
                                VStack {
                                    Gauge(value: Double(entrySteps), in: 0...Double(AppConfig.shared.targetSteps)) {
                                        
                                    } currentValueLabel: {
                                        Image("figure.prothese")
                                            .imageScale(.large)
                                            .font(.system(size: 30))
                                            .foregroundColor(.white)
                                    }
                                    .gaugeStyle(.accessoryCircularCapacity)
                                    .widgetAccentable()
                                }
                            }
                        }
                    }.widgetURL(entry.url)
                case .accessoryRectangular:
                    ZStack {
                        
                        hasProFeatureOverlay(binding: !entry.hasUnlockedPro) { state in
                            ViewThatFits {
                                HStack {
                                    VStack {
                                        Image("figure.prothese")
                                            .font(.system(size: 25))
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("\(entryWorkouts)")
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
                        
                        hasProFeatureOverlay(binding: !entry.hasUnlockedPro) { state in
                            
                            ViewThatFits {
                                HStack{
                                    Image("figure.prothese")
                                        .imageScale(.large)
                                        .font(.system(size: 30))
                                    
                                    Text("\(entryWorkouts) Steps")
                                }
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
            let DateIndterval = DateInterval(start: Calendar.current.startOfDay(for: Date()), end: Date())
            
            HealthStoreProvider().queryWidgetSteps(completion: { stepCount, error in
                if error?._code == 6 {
                    print("WA: \(self.entrySteps)")
                } else {
                    self.entrySteps = Int(stepCount)
                }
                self.entryDate = Date().dateFormatte(date: "dd.MM.yyyy", time: "HH:mm").date + " " + Date().dateFormatte(date: "dd.MM.yyyy", time: "HH:mm").time
                
                HealthStoreProvider().getWorkouts(week: DateIndterval, workout: .default(), completion: { workouts in
                    let (h,m,s) = secondsToHoursMinutesSeconds(Int(workouts.data.last?.value ?? 0.1))
                    self.entryWorkouts = h + ":" + m + ":" + s
                })
            })
        })
        .onChange(of: entry.date, perform: { newDate in
            let DateIndterval = DateInterval(start: Calendar.current.startOfDay(for: newDate), end: newDate)
            HealthStoreProvider().queryWidgetSteps(completion: { stepCount, error in               
                
                
                if error?._code == 6 {
                    print("WC: \(self.entrySteps)")
                } else {
                    self.entrySteps = Int(stepCount)
                }
                
                self.entryDate = Date().dateFormatte(date: "dd.MM.yyyy", time: "HH:mm").date + " " + Date().dateFormatte(date: "dd.MM.yyyy", time: "HH:mm").time
                
                HealthStoreProvider().getWorkouts(week: DateIndterval, workout: .default(), completion: { workouts in
                    let (h,m,s) = secondsToHoursMinutesSeconds(Int(workouts.data.last?.value ?? 0.1))
                    self.entryWorkouts = h + ":" + m + ":" + s
                })
            })
        })
    }
    
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (String, String, String) {
        let hour = String(format: "%02d", seconds / 3600)
        let minute = String(format: "%02d", (seconds % 3600) / 60)
        let second = String(format: "%02d", (seconds % 3600) % 60)
        return (hour, minute, second)
    }
}

class EntryCache {
    var previousEntry: SimpleEntry?
}

struct ProProtheseWidgetTodayWorkouts: Widget {
    
    let kind: String = "ProProtheseWidgetTodayWorkouts"
    
    private var supportedFamilies:[WidgetFamily] = [
        .systemSmall,
        .accessoryCircular,
        .accessoryRectangular,
        .accessoryInline
    ]
    
    @State var entryError: Error?
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayWorkoutsProvider(unlocked: AppTrailManager.hasProOrFreeTrail)) { entry in
            ProProtheseWidgetTodayWorkoutsEntryView(entry: entry)
                .background(.clear)
                .cornerRadius(20)
        }
        .supportedFamilies(supportedFamilies)
        .configurationDisplayName("Prosthesis wearing time")
        .description("See your daily progress everywhere")
      
    }
}

struct ProProtheseWidgetTodayWorkouts_Previews: PreviewProvider {
    
    var nextUpdate: Date
    
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
                ProProtheseWidgetTodayWorkoutsEntryView(
                    entry: TodayWorkoutsSimpleEntry(
                        date: Date(),
                        nextUpdate: Calendar.current.date(byAdding: .minute, value: 1 , to: Date())!,
                        url: URL(string: "ProProthese://statisticWorkout"),
                        hasUnlockedPro: false
                    )
                )
                .background(.clear)
                .cornerRadius(20)
                .previewContext(WidgetPreviewContext(family: item.widget))
                .previewDisplayName("\(item.name)")
            }
 
        }
    }
}
