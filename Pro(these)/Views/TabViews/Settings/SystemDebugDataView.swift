//
//  SystemDebugDataView.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 15.08.23.
//

import SwiftUI

struct SystemDebugDataView: View {
    
    private var titel: LocalizedStringKey
    @EnvironmentObject var themeManager: ThemeManager

    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @StateObject var appConfig = AppConfig()
    
    @StateObject var handlerStates = HandlerStates.shared
    
    @FetchRequest var allBackgroundTasks: FetchedResults<BackgroundTaskItem>


    
    init(titel: LocalizedStringKey) {
        _allBackgroundTasks = FetchRequest<BackgroundTaskItem>(
            sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)]
        )
        
        self.titel = titel
    }
    
    private func BackgroundTasks(data: String) -> [BackgroundTask] {
        let d = data
            .components(separatedBy: "\n")
            .map({ string in
                string.components(separatedBy: ",")
            }).map({
                BackgroundTask(name: $0[0], value: $0[1])
            })

        return d
    }
    
    var body: some View {
        ZStack {
            currentTheme.gradientBackground(nil)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10){
                    HStack{
                        Text(titel)
                            .foregroundColor(currentTheme.text)
                    }
                    .padding(.vertical)
                }
                .padding(.top)
                
                
                VStack(spacing: 10) {
                    HStack {
                        let firstAppLaunch = handlerStates.firstLaunchDate.dateFormatte(date: "dd.MM", time: "HH:mm")
                        Label("First Launch: " + firstAppLaunch.date + " " + firstAppLaunch.time, systemImage: "person.crop.circle.badge.clock")
                        Spacer()
                    }
                    
                    HStack {
                        let lastAppLaunch = handlerStates.LastLaunchDate.dateFormatte(date: "dd.MM", time: "HH:mm")
                        Label("Last Launch: " + lastAppLaunch.date + " " + lastAppLaunch.time, systemImage: "person.crop.circle.badge.clock")
                        Spacer()
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        StateMenu()
                            .padding(.leading)
                        
                        NotificationMenus()
                            .padding(.trailing)
                    }
                }
                .foregroundColor(currentTheme.text)

                ForEach(allBackgroundTasks, id: \.id) { task in
                    
                    VStack(spacing: 20) {
                        VStack {
                            HStack(spacing: 10) {
                                Text("Task:")
                                Text(task.task ?? "")
                                Spacer()
                            }
                            
                            HStack(spacing: 10) {
                                Text("Action:")
                                Text(task.action ?? "")
                                Spacer()
                            }
                            
                            HStack(spacing: 10) {
                                Text("Date:")
                                
                                let d = task.date?.dateFormatte(date: "dd.MM.yy", time: "HH.mm") ?? Date().dateFormatte(date: "dd.MM.yy", time: "HH.mm")
                                
                                Text(d.date + "-" + d.time)
                                Spacer()
                            }
                        }

                        if let data = task.data {
                            VStack {
                                ForEach(BackgroundTasks(data: data), id: \.name) { task in
                                    HStack(spacing: 10) {
                                        Text(task.name)
                                            .font(.footnote)
                                        Spacer()
                                        Text(task.value)
                                            .font(.footnote.bold())
                                    }
                                }
                            }
                        }
                        
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .padding()
                    
                }
                
            }
            
        }
    }
    
    func NotificationMenus() -> some View {
        Menu("Notification Menus", content: {
            
            Menu("HealthKit Querys", content: {
                
                Toggle("AppDelegate Trigger", isOn: $handlerStates.DEBUGAppDelegateTrigger)
                
                Toggle("When BG Task is running", isOn: $handlerStates.DEBUGBG_Tasks)
                
                Toggle("healthStore HKObserverQuery Errors", isOn: $handlerStates.DEBUGStepProvider)
                
                Toggle("healthStore Provider Errors", isOn: $handlerStates.DEBUGStepProviderErrors)
            })
            
        })
        .menuOrder(.fixed)
        .buttonStyle(.bordered)
    }
    
    func StateMenu() -> some View {
        Menu("States", content: {
            
            Button("Delete All Stored BackgroundTaskItems") {
                let _ = allBackgroundTasks.map({
                    PersistenceController.shared.container.viewContext.delete($0)
                    try? PersistenceController.shared.container.viewContext.save()
                })
            }
            
            Menu("Notification Handler States", content: {
                Button("Reset step goal 50% reached message Date") {
                    handlerStates.sendReachedHalfTargetStepsNotificationDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
                }
                
                Button("Reset step goal reached message Date") {
                    handlerStates.sendReachedFullTargetStepsNotificationDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
                }
                
                Button("Set LastLaunchDate -33h") {
                    handlerStates.LastLaunchDate = Calendar.current.date(byAdding: .hour, value: -33, to: Date())!
                }
                
                Button("Set FirstLaunchDate to now") {
                    handlerStates.firstLaunchDate = Date()
                }
                
                Button("Set FirstLaunchDate to -1 Day") {
                    handlerStates.firstLaunchDate = Calendar.current.date(byAdding: .day, value: -1, to: handlerStates.firstLaunchDate)!
                }
                
                Button("Set Report -1 Day") {
                    handlerStates.weeklyProgressReportNotification = Calendar.current.date(byAdding: .day, value: -1, to: handlerStates.weeklyProgressReportNotification)!
                }
            })
        })
        .menuOrder(.fixed)
        .buttonStyle(.bordered)
    }
}

struct SystemDebugDataView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Menu("States", content: {
                
                Button("Delete All Stored BackgroundTaskItems") {
                    
                }
                
                Menu("Notification Handler States", content: {
                    Button("Reset Half State") {
                        //handlerStates.sendReachedHalfTargetStepsNotification = false
                    }
                    
                    Button("Reset Half State") {
                        //handlerStates.sendReachedFullTargetStepsNotification = false
                    }
                    
                    Button("Reset Half State") {
                        //handlerStates.LastLaunchDate = Calendar.current.date(byAdding: .hour, value: -32, to: Date())!
                    }
                })
                
            })
            
            
            Spacer()
        }
    }
}
