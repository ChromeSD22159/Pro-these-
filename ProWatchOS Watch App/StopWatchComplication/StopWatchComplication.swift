//
//  StopWatchComplication.swift
//  StopWatchComplication
//
//  Created by Frederik Kohler on 15.06.23.
//

import WidgetKit
import SwiftUI
import HealthKit
import Foundation

struct Provider: TimelineProvider {
    var workoutManager: WorkoutManager
    
    var stateManager: StateManager
    
    var url = URL(string: "ProProthese://stopWatch")
    
    var entrySteps: Double
    var entryWorkouts: Double
    
    
    var nextUpdate: Date {
        return Calendar.current.date(byAdding: .second, value: 5, to: Date())!
    }

    var dummySteps: (min: Int, max: Int, current: Int, error: Error?) {
        return (min: 0, max: AppConfig.shared.targetSteps, current: 4567, error: nil)
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), nextUpdate: nextUpdate, url: self.url!, steps: dummySteps, isRunning: false, timer: Date(), workout: 0.1)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), nextUpdate: nextUpdate, url: self.url!, steps: dummySteps, isRunning: false, timer: Date(), workout: 0.1)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        
        let update = Calendar.current.date(byAdding: .second, value: 5, to: currentDate)!
        
        let userDefaults = UserDefaults(suiteName: "group.FK.Pro-these-")
        userDefaults?.synchronize()
        
        let s: (min: Int, max: Int, current: Int, error: Error?) = (min: 0, max: AppConfig.shared.targetSteps, current: Int(entrySteps), error: nil)
        
        let entrie = SimpleEntry(date: Date(), nextUpdate: update, url: self.url, steps: s, isRunning: stateManager.state, timer: currentDate, workout: entryWorkouts)
        let timeline = Timeline(entries: [entrie], policy: .after(update))
        completion(timeline)
    }
    
    func recorderFetchStartTime() -> Bool {
        if (UserDefaults.standard.object(forKey: "startTime") != nil) {
            return true
        } else {
            return false
        }
    }
    
    func CheckRecorder() -> Bool {
        if (UserDefaults(suiteName: "group.FK.Pro-these-")?.object(forKey: "startTime") != nil) {
            return true
        } else {
            return false
        }
    }

}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let nextUpdate: Date
    let url: URL?
    let steps: (min: Int , max: Int , current: Int, error: Error?)
    let isRunning: Bool
    let timer: Date
    let workout: Double
}

struct StopWatchComplicationEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    
    private var percentSteps: Int {
        return Int(self.entry.steps.current) / AppConfig.shared.targetSteps * 100
    }
    
    @AppStorage("TimerState", store: UserDefaults(suiteName: "group.FK.Pro-these-")) var isRunning: Bool = false
    
    @State var stateManager = StateManager.sharedManager
    
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
        .onAppear {
            print(stateManager.state)
        }
        .widgetURL(entry.url)
    }
    
    @ViewBuilder
    func Circular(steps: (min: Int, max: Int, current: Int, error: (any Error)?)) -> some View{
        VStack(spacing: 1) {
            
            let gradient = Gradient(colors: [.white.opacity(0.5), Theme.blue.backgroundColor])
            
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
        Text("🦿")
            .font(.system(size: 35))
            .widgetLabel(label: {
                let (h,m,s) = secondsToHoursMinutesSeconds(Int(entry.workout))
                
                Text("\(h):\(m):\(s)")
                    .font(.body.bold())
            })
    }
    
    @ViewBuilder
    func Rectangular(steps: (min: Int, max: Int, current: Int, error: (any Error)?)) -> some View {
        ZStack {
            VStack(alignment: .leading, spacing: 5) {

                HStack {
                    
                    let (h,m,s) = secondsToHoursMinutesSeconds(Int(entry.workout))
                    
                    if !isRunning {
                        HStack(alignment: .center) {
                            Text("🦿")
                            
                            
                            Text("\(h):\(m):\(s)")
                                .font(.body.bold())
                            
                            Spacer()
                            
                            Text(isRunning ? "T":" ")
                                .font(.body.bold())
                            
                            Image(systemName: "stopwatch")
                                .font(.body.bold())
                                .foregroundColor(.yellow)
                                .padding(.trailing, 10)
                                .opacity(0)
                        }
                    } else {
                        HStack(alignment: .center) {
                            Text("🦿")
                            
                            Text("\(h):\(m):\(s)")
                                .font(.system(size: 20).bold())
                            
                            Spacer()
                            
                            Image(systemName: "stopwatch")
                                .font(.body.bold())
                                .foregroundColor(.yellow)
                                .padding(.trailing, 10)
                        }
                    }
                    
                }
                
                HStack {
                    
                    VStack {
                        
                        let gradient = Gradient(colors: [.white.opacity(0.5), Theme.blue.backgroundColor])
                        
                        Gauge(value: Double(entry.steps.current), in: 0...Double(AppConfig.shared.targetSteps)) {
                        } currentValueLabel: {
                            
                        }
                        .gaugeStyle(.accessoryLinear)
                        .tint(gradient)
                       
                        HStack {
                            Text("\(Int(steps.current)) Steps")
                                .font(.system(size: 10).bold())
                                .padding(.leading, 5)
                            
                            Spacer()
                            
                            Text("time: " + entry.nextUpdate.formatteTime(time: "HH:mm")).font(.system(size: 10).bold())
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
                        Image("figure.prothese")
                            .imageScale(.large)
                            .font(.system(size: 30))
                    }
               
            }
        }
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (String, String, String) {
        let hour = String(format: "%02d", seconds / 3600)
        let minute = String(format: "%02d", (seconds % 3600) / 60)
        let second = String(format: "%02d", (seconds % 3600) % 60)
        return (hour, minute, second)
    }
}

@main
struct StopWatchComplication: Widget {
    let kind: String = "StopWatchComplication"
    
    private var supportedFamilies:[WidgetFamily] = [
        .accessoryCircular,
        .accessoryCorner,
        .accessoryRectangular
    ]
    
    let hm = WorkoutManager()
    
    @StateObject var stateManager = StateManager()
    
    @AppStorage("Entry steps") var entrySteps: Double = 0
    @AppStorage("Entry workouts") var entryWorkouts: Double = 0
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(workoutManager: hm, stateManager: stateManager, entrySteps: entrySteps, entryWorkouts: entryWorkouts)) { entry in
            StopWatchComplicationEntryView(entry: entry)
                .onAppear{
                    let DateIndterval = DateInterval(start: Calendar.current.startOfDay(for: Date()), end: Date())
                    
                    hm.queryWidgetSteps(completion: { res, err in

                        hm.getWorkouts(week: DateIndterval, workout: .default(), completion: { workouts in
                           
                            if err?._code == 6 {
                                
                            } else {
                                self.entrySteps = res
                            }
                            self.entryWorkouts = workouts.data.last?.value ?? 0.1
                        })
                    })
                }
                .onChange(of: entry.date, perform: { newDate in
                    let DateIndterval = DateInterval(start: Calendar.current.startOfDay(for: Date()), end: Date())
                    
                    hm.queryWidgetSteps(completion: { res, err in

                        hm.getWorkouts(week: DateIndterval, workout: .default(), completion: { workouts in
                           
                            if err?._code == 6 {
                                
                            } else {
                                self.entrySteps = res
                            }
                            self.entryWorkouts = workouts.data.last?.value ?? 0.1
                        })
                    })
                })
            
        }
        .configurationDisplayName("prosthesis timer")
        .supportedFamilies(supportedFamilies)
        .description("Start and end your prosthetic times quickly.")
    }
}

struct StopWatchComplication_Previews: PreviewProvider {
    static var nextUpdate: Date {
        return Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
    }

    static var dummySteps: (min: Int, max: Int, current: Int, error: Error?) {
        return (min: 0, max: 10000, current: 4567, error: nil)
    }
    
    static var supportedFamilies:[(widget: WidgetFamily, name: String)] = [
        (widget: .accessoryCircular, name: "Circular"),
        (widget: .accessoryCorner, name: "Corner"),
        (widget: .accessoryRectangular, name: "Regangular"),
        (widget: .accessoryInline, name: "Inline")
    ]
    
    static var previews: some View {
        let url = URL(string: "ProProthese://pain")
        let entry = SimpleEntry(date: Date(), nextUpdate: nextUpdate, url: url!, steps: dummySteps, isRunning: true, timer: Date(), workout: 0.12)
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
