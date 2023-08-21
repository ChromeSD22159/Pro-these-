

import SwiftUI
import HealthKit
import Combine
import Foundation
import WidgetKit
import GoogleMobileAds
import BackgroundTasks
import CoreData

@main
struct Pro_theseApp: App {
    let adsVM = AdsViewModel.shared
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase
    
    let healthKitManager = HealthStoreProvider()
    
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
    @StateObject var themeManager = ThemeManager()
    
    @AppStorage("Days") var fetchDays:Int = 7
    @State private var LaunchScreen = true
    @State var deepLink:URL?
    @StateObject private var loginViewModel = LoginViewModel()
    
    
    @StateObject private var entitlementManager: EntitlementManager

    @StateObject private var purchaseManager: PurchaseManager
    
    @StateObject private var appConfig = AppConfig()
    
    @State var notes: [UNNotificationRequest] = []
    
    @State var badgeManager = AppAlertBadgeManager(application: UIApplication.shared)
    
    init() {
        let entitlementManager = EntitlementManager()
        let purchaseManager = PurchaseManager(entitlementManager: entitlementManager)

        self._entitlementManager = StateObject(wrappedValue: entitlementManager)
        self._purchaseManager = StateObject(wrappedValue: purchaseManager)
        
        healthKitManager.setUpHealthRequest(healthStore: healthKitManager.healthStore, readSteps: {
            
        })
    }
    
    let locationProvider = LocationProvider()

    var body: some Scene {
        WindowGroup {
            ZStack{
                
                if loginViewModel.appUnlocked || AppConfig.shared.faceID == false {
                    
                    if let defaults = UserDefaults(suiteName: "group.FK.Pro-these-") {
                        ContentView(deepLink: $deepLink)
                            .colorScheme(.dark)
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                            .environmentObject(appConfig)
                            .environmentObject(themeManager)
                            .environmentObject(TabManager())
                            .environmentObject(healthStorage)
                            .environmentObject(locationProvider)
                            .environmentObject(pushNotificationManager)
                            .environmentObject(eventManager)
                            .environmentObject(adsVM)
                            .environmentObject(cal)
                            .environmentObject(workoutStatisticViewModel)
                            .environmentObject(painViewModel)
                            .environmentObject(stateManager)
                            .environmentObject(entitlementManager)
                            .environmentObject(purchaseManager)
                            .environmentObject(appDelegate)
                            .defaultAppStorage(defaults)
                            .onChange(of: scenePhase) { newPhase in
                                if newPhase == .active {
                                    onOpenApp()
                                } else if newPhase == .inactive {
                                    WidgetCenter.shared.reloadAllTimelines()
                                } else if newPhase == .background {
                                    print("APP changed to Background \(Date())")
                                   
                                    loginViewModel.appUnlocked = false
                                    
                                    AppRemoveNotifications.setMoodReminderNotifications()
                                    AppRemoveNotifications.setGoodMorningNotifications()
                                    AppRemoveNotifications.setComebackNotifications(delay: Int.random(in: (6*60*60)...(8*60*60))) // 6h - 8h
                                    
                                    registerAppBackgroundTask()
                                    
                                    Task {
                                        await StepBadgeManager.updateHandler()
                                    }
                                    
                                    WidgetCenter.shared.reloadAllTimelines()
                                }
                            }
                            .task {
                               await purchaseManager.updatePurchasedProducts()
                            }
                        
                    } else {
                        Text("Error loading AppGroup")
                    }

                } else {
                    LoginScreen()
                        .environmentObject(themeManager)
                        .onChange(of: scenePhase) { newPhase in
                            if newPhase == .active {
                                loginViewModel.requestBiometricUnlock(type: .faceID)
                            } 
                        }
                        .environmentObject(loginViewModel)
                }

             
                if LaunchScreen {
                    LaunchScreenView()
                        .environmentObject(themeManager)
                }

             
            }
            .onAppear{
                onOpenApp()                
            }
            
        }
        .backgroundTask(.appRefresh("refresh"), action: {
            if WeeklyProgressReportManager.requestCoreDataHandler {
                if AppConfig.shared.PushNotificationReports {
                    await pushNotificationManager.ReportNotification()
                }
            }
            
            if AppFirstLaunchManager.requestMissingMessage {
                await pushNotificationManager.MissingNotification()
            }
            
            
            if AppConfig.shared.adsDebug {
                if HandlerStates().DEBUGBG_Tasks {
                    await pushNotificationManager.PushNotificationByTimer(
                            identifier: "BG_TASK",
                            title: "New BG TASK is running",
                            body: "The App triggered a new BG TASK.",
                            triggerTimer: 1,
                            url: ""
                    )
                }
            }

            WidgetCenter.shared.reloadAllTimelines()
            
            // register the next BG Task
            await registerAppBackgroundTask()
        })
    }

    func removeNotifications() {
        loadNotifications()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            AppRemoveNotifications.removeNotifications(keyworks: ["MOOD_REMINDER", "MOOD_GOOD_MORNING", "COMEBACK_REMINDER", "MISSING_REMINDER"], notes: notes)
        })
    }
    
    func loadNotifications() {
        PushNotificationManager().getAllPendingNotifications(debug: false) { note in
            DispatchQueue.main.async {
                notes.append(note)
            }
        }
    }
    
    func onOpenApp() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            withAnimation(.easeOut(duration: 2.0)) {
                LaunchScreen = false
            }
        })

        removeNotifications()
        
        AppFirstLaunchManager.requestFirstLaunch(debug: false)
        AppFirstLaunchManager.updateLaunchDate()

        let deviceLanguage = Bundle.main.preferredLocalizations.first
        LanguageController.shared.setLanguage(deviceLanguage!)
        
        if !self.appConfig.hasPro {
            self.appConfig.faceID = false
            self.appConfig.PushNotificationDailyMoodRemembering = true
            self.appConfig.PushNotificationComebackReminder = true
            self.appConfig.PushNotificationGoodMorning = true
        }
    }
    
    func registerAppBackgroundTask() {
        let backgroundTask = BGAppRefreshTaskRequest(identifier: "refresh")

        do {
            try? BGTaskScheduler.shared.submit(backgroundTask)
            print("Successfully scheduled a background task ")
        }
    }
}



class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, ObservableObject {
    
    @StateObject var handler = HandlerStates()

    let healthKitManager = HealthStoreProvider()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if !AppConfig.shared.hasPro {
          if AppConfig.shared.adsDebug {
                GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "550578b8f99033c15cec59b88b2e9249" ]
            } else {
                GADMobileAds.sharedInstance().start(completionHandler: nil)
            }
        }

        
        /* TEST */
        UNUserNotificationCenter.current().delegate = self

        
        if AppConfig.shared.adsDebug {
            if HandlerStates.shared.DEBUGAppDelegateTrigger {
                PushNotificationManager().PushNotificationByTimer(
                    identifier: "AppDelegate",
                    title: "Observing AppDelegate Action",
                    body: "Action in AppDelegate ditected",
                    triggerTimer: 1,
                    url: "",
                    printConsole: true
                )
            }
        }

        healthKitManager.updateStepData { steps, error  in
            guard error == nil else {
                print(error?.localizedDescription ?? "healthKitManager.updateStepData error")
                return
            }
            
            print(error?.localizedDescription ?? "No healthKitManager.updateStepData error")
            
            if AppConfig.shared.adsDebug {
                if HandlerStates.shared.DEBUGAppDelegateTrigger {
                    PushNotificationManager().PushNotificationByTimer(
                            identifier: "BG_TASK_Steps",
                            title: "Observing Steps from Delegade",
                            body: "Observing Steps: \(Int(steps ?? 0)) Steps",
                            triggerTimer: 1,
                            url: ""
                    )
                }
            }

            if StepNotificationRequest.requestHandlerForHalfStepsGoal(debug: false, steps: Int(steps ?? 0), stepsDate: Date(), error: error) {
                PushNotificationManager().reachedHalfOfTargetStepsNotification(steps: Int(steps ?? 0))
            }
            
            if StepNotificationRequest.requestHandlerForFullStepsGoal(debug: false, steps: Int(steps ?? 0), stepsDate:  Date(), error: error) {
                PushNotificationManager().reachedFullOfTargetStepsNotification(steps: Int(steps ?? 0))
            }
            
            if HandlerStates.showBadgeSteps {
                StepBadgeManager.badgeManager.setAlertBadge(number: Int(steps ?? 0))
            } else {
                StepBadgeManager.badgeManager.resetAlertBadgetNumber()
            }
        }
        
        WidgetCenter.shared.reloadAllTimelines()
        
        return true
    }
    
    // notification when app is active
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        UNUserNotificationCenter.current().delegate = self

        print("willPresent ID: \(userInfo)")
        
        HandlerStates.shared.msgDeepLink = userInfo.map({
            $0.value
        }).first as! String
    }

    
    // notification when app is in background
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        UNUserNotificationCenter.current().delegate = self
        
        let userInfo = response.notification.request.content.userInfo

        print("didReceive ID: \(userInfo)")
        
        HandlerStates.shared.msgDeepLink = userInfo.map({
            $0.value
        }).first as! String
        
        print("didReceive ID: \(HandlerStates.shared.msgDeepLink)")
    }
}
