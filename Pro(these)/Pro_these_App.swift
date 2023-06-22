

import SwiftUI
import HealthKit
import Combine
import Foundation
import WidgetKit

@main
struct Pro_theseApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    var persistenceController = PersistenceController.shared
    @StateObject var healthStorage = HealthStorage()
    @StateObject var pushNotificationManager = PushNotificationManager()
    @StateObject var tabManager = TabManager()
    @StateObject var eventManager = EventManager()
    @StateObject var cal = MoodCalendar()
    @StateObject var workoutStatisticViewModel = WorkoutStatisticViewModel()
    @StateObject var painViewModel = PainViewModel()
    @StateObject var stopWatchProvider = StopWatchProvider()
    @StateObject var stateManager = StateManager()
    
    @AppStorage("Days") var fetchDays:Int = 7
    @State private var LaunchScreen = true
    @State var deepLink:URL?
    @StateObject private var loginViewModel = LoginViewModel()
    
    
    @StateObject private var entitlementManager: EntitlementManager

    @StateObject private var purchaseManager: PurchaseManager
    
    @State var identifier = "de-DE"
    
    init() {
        let entitlementManager = EntitlementManager()
        let purchaseManager = PurchaseManager(entitlementManager: entitlementManager)

        self._entitlementManager = StateObject(wrappedValue: entitlementManager)
        self._purchaseManager = StateObject(wrappedValue: purchaseManager)
        
        HealthStoreProvider().setUpHealthRequest(healthStore: HKHealthStore(), readSteps: {
            
        })
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack{
                
                if loginViewModel.appUnlocked || AppConfig.shared.faceID == false {
                    
                    if let defaults = UserDefaults(suiteName: "group.FK.Pro-these-") {
                        ContentView(loc: LocationProvider.shared.getLocation(), deepLink: $deepLink)
                            .colorScheme(.dark)
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
                            .environmentObject(entitlementManager)
                            .environmentObject(purchaseManager)
                            .defaultAppStorage(defaults)
                            .environment(\.locale, .init(identifier: identifier))
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
                            .task {
                               await purchaseManager.updatePurchasedProducts()
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
                pushNotificationManager.registerForPushNotifications()
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
                        print("ON OPEN: \(deepLink)")
                        deepLink = url
                    } else {
                        deepLink = nil
                    }
                })
            }
        }
    }
}

