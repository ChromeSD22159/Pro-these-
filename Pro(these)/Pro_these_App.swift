

import SwiftUI
import HealthKit
import Combine
import Foundation
import WidgetKit

@main
struct Pro_theseApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    let persistenceController = PersistenceController.shared
    let healthStorage = HealthStorage()
    let pushNotificationManager = PushNotificationManager()
    let tabManager = TabManager()
    let eventManager = EventManager()
    let cal = MoodCalendar()
    let workoutStatisticViewModel = WorkoutStatisticViewModel()
    let painViewModel = PainViewModel()
    
    @StateObject var stateManager = StateManager()
    
    @AppStorage("Days") var fetchDays:Int = 7
    @State private var LaunchScreen = true
    @State var deepLink:URL?
    @StateObject private var loginViewModel = LoginViewModel()
    
    init() {
        pushNotificationManager.registerForPushNotifications()
        HealthStoreProvider().setUpHealthRequest(healthStore: HKHealthStore(), readSteps: {
            
        })
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack{
                if loginViewModel.appUnlocked {
                    
                    if let defaults = UserDefaults(suiteName: "group.FK.Pro-these-") {
                        ContentView(loc: LocationProvider.shared.getLocation(), deepLink: $deepLink)
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                            .environmentObject(AppConfig())
                            .environmentObject(TabManager())
                            .environmentObject(healthStorage)
                            .environmentObject(pushNotificationManager)
                            .environmentObject(eventManager)
                            .environmentObject(cal)
                            .environmentObject(workoutStatisticViewModel)
                            .environmentObject(painViewModel)
                            .environmentObject(stateManager)
                            .defaultAppStorage(defaults)
                            .onChange(of: scenePhase) { newPhase in
                                if newPhase == .active {
                                    pushNotificationManager.removeNotificationsWhenAppLoads()
                                    
                                } else if newPhase == .inactive {
                                
                                } else if newPhase == .background {
                                    print("APP changed to Background")
                                    loginViewModel.appUnlocked = false
                                    if !AppConfig().PushNotificationDisable {
                                        pushNotificationManager.setUpNonPermanentNotifications()
                                    }
                                  
                                }
                            }
                    } else {
                        Text("Fehler beim Laden der AppGroup")
                    }
                    
                    
                
                } else {
                    LoginScreen()
                        .onChange(of: scenePhase) { newPhase in
                            if newPhase == .active {
                                loginViewModel.requestBiometricUnlock(type: .faceID)
                            } 
                        }
                        .environmentObject(loginViewModel)
                }
                
                
             
                if LaunchScreen {
                    LaunchScreenView()
                }

             
            }
            .onAppear{
                WidgetCenter.shared.reloadAllTimelines()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    withAnimation(.easeOut(duration: 2.0)) {
                        LaunchScreen = false
                    }
                })
            }
            .onOpenURL { url in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    if url.scheme == "ProProthese" {
                        deepLink = url
                    } else {
                        deepLink = nil
                    }
                })
            }
        }
    }
}

