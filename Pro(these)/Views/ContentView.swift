//
//  ContentView.swift
//  Pro Prothese
//
//  Created by Frederik Kohler on 23.04.23.
//

import SwiftUI
import CoreData
import MapKit
import StoreKit

struct ContentView: View {
    @Environment(\.requestReview) var requestReview
    @Binding var deepLink: URL?
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject private var tabManager: TabManager
    @EnvironmentObject private var healthStore: HealthStorage
    @EnvironmentObject private var cal: MoodCalendar
    @EnvironmentObject var pain: PainViewModel
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var locationManager: LocationProvider
    @State var activeTab: Tab = .healthCenter
    @State var activeSubTab: SubTab = .event
    @State var overlay = false
    
    @State var showSubTab = false
    @StateObject var location = LocationProvider()
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @State var username = ""
    
    @State var amputationDate = Date()
    
    @State var prosthesisDate = Date()
    
    @State var targetSteps = 0
    
    @State var isSetupSheet = false
    
    @State var openSetupSheetFromSettingsSheet = false
    
    @AppStorage("showReportSheet", store: AppConfig.store) var showReportSheet = false
    
    var body: some View {
        
        GeometryReader { proxy in
            NavigationView {
                ZStack {
                    // Background Darkblue
                    currentTheme.backgroundColor
                    
                    // Background Darkblue with transparent RadialGradient
                    currentTheme.radialBackground(unitPoint: nil, radius: nil)
                        .ignoresSafeArea()
                    
                    // Background Circle Animation
                    CircleAnimationInBackground(delay: 1, duration: 2)
                        .opacity(0.2)
                        .ignoresSafeArea()
                    
                    // Map only Show when StopWatch View is Active
                    if activeTab == .stopWatch {
                        Map(coordinateRegion: $locationManager.region, showsUserLocation: true)
                            .onAppear {
                                locationManager.startMonitoring()
                            }
                            .onDisappear {
                                locationManager.stopMonitoring()
                            }
                        // overlay
                        currentTheme.mapOverlayBackground.ignoresSafeArea()
                    }
                    
                    // Content
                    VStack(){
                        switch activeTab {
                        case .home: HomeView().padding(.bottom, !AppConfig.shared.hasPro ? 60 : 10)
                        case .event: Events().padding(.bottom, !AppConfig.shared.hasPro ? 60 : 10)
                        case .healthCenter: WorkOutEntryView().padding(.bottom, !AppConfig.shared.hasPro ? 60 : 10)
                        case .stopWatch: StopWatchView().padding(.bottom, !AppConfig.shared.hasPro ? 60 : 10)
                        case .add: FeelingView().padding(.bottom, !AppConfig.shared.hasPro ? 60 : 10)
                        case .feeling: FeelingView().padding(.bottom, !AppConfig.shared.hasPro ? 60 : 10)
                        case .pain: PainEntry().padding(.bottom, !AppConfig.shared.hasPro ? 60 : 10)
                        }
                        
                        Spacer(minLength: 70)
                    }
                    .foregroundColor(currentTheme.accentColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .blur(radius: showReportSheet ? 4 : 0)
                    
                    // Navigation
                    VStack(spacing: 0){
                        if showSubTab {
                            ZStack{
                                currentTheme.textBlack.ignoresSafeArea().opacity(showSubTab ? 0.5 : 0)
                                currentTheme.radialBackground(unitPoint: nil, radius: nil).ignoresSafeArea().opacity(showSubTab ? 0.5 : 0)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            .background(Material.ultraThinMaterial.opacity(showSubTab ? 0.5 : 0))
                            .ignoresSafeArea().opacity(showSubTab ? 1 : 0)
                            .onTapGesture{
                                withAnimation(.easeInOut(duration: 0.3)){
                                    showSubTab.toggle()
                                }
                            }
                        } else {
                            Spacer()
                        }
                        
                        // NavBar
                        TabStack(deepLink: $deepLink, activeTab: $activeTab, activeSubTab: $activeSubTab, showSubTab: $showSubTab)
                            .frame(height: !AppConfig.shared.hasPro ? 70 : 50)
                            .offset(y: -15)
                            
                        
                        if !AppConfig.shared.hasPro {
                            AdsManager.AdBannerView(adUnitID: AdsManager.GoogleAds.banner.blockID(type: appConfig.adsDebug ? .test : .product) , height: nil, width: nil )
                                .ignoresSafeArea()
                                .frame(height: 50)
                        }
                        
                    }
                    .foregroundColor(currentTheme.accentColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .blur(radius: showReportSheet ? 4 : 0)
                    
                    // Header blur
                    HeaderBackgroundBlurTop()
                    
                    // MARK: - REPROT
                    ReportOverlayView()
                    
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
        }
        // Settings Sheet
        .fullScreenCover(isPresented: $tabManager.isSettingSheet, onDismiss: {
            appConfig.username = username
            appConfig.amputationDate = amputationDate
            appConfig.prosthesisDate = prosthesisDate
            appConfig.targetSteps = targetSteps
            
            if openSetupSheetFromSettingsSheet {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    isSetupSheet = true
                    
                    openSetupSheetFromSettingsSheet = false
                })
            }
            
        }, content: {
            SettingsSheet(
                username: $username,
                amputationDate: $amputationDate,
                prosthesisDate: $prosthesisDate,
                openSetupSheetFromSettingsSheet: $openSetupSheetFromSettingsSheet,
                targetSteps: $targetSteps
            )
        })
        .blurredOverlaySheet(.init(.ultraThinMaterial), show: $tabManager.ishasProFeatureSheet, onDismiss: {
            print("dismiss ProFeatureSheet")
        }, content: {
            ProFeatureSheet()
        })
        .fullScreenCover(isPresented: $tabManager.isSetupSheet, onDismiss: {}) {
            SetupView()
                .background(RemoveBackgroundColor())
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea(.container, edges: .all)
                )
        }
        .fullScreenCover(isPresented: $isSetupSheet, onDismiss: {}) {
            SetupView()
                .background(RemoveBackgroundColor())
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea(.container, edges: .all)
                )
        }
        .blurredSheet(.init(.ultraThinMaterial), show: $tabManager.isSuggestionSheet, onDismiss: {
            
        }){
            SuggestionSheet()
        }
        // Overlay
        .overlay(overlay ? Launch_Screen().opacity(1) : Launch_Screen().opacity(0), alignment: .topTrailing)
        // Set EntryView from User Settings
        .onOpenURL(perform: { url in
            print("Content: entryTab: \(url)")
            if let EntryLink = url.tabIdentifier {
                activeTab = EntryLink
            } else {
                activeTab = AppConfig.shared.entrySite
            }
        })
        .onAppear{
            setupSettingVariables()
            
            if activeTab == .stopWatch {
                locationManager.startMonitoring()
            } else {
                locationManager.stopMonitoring()
            }
            
            checkSetupSheet(.production)
            
            AppStoreReviewRequest.checkRequestReview() { state in
                if state {
                    requestReview()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)) { _ in
            overlay.toggle()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 ) {
                overlay.toggle()
            }
        }
        .task {
            do {
                try await purchaseManager.loadProducts()
            } catch {
                print(error.localizedDescription)
            }
        }
        .viewSize(sizeBinding: .constant(CGSize()), printInConsole: false, viewName: "Tabstack")
    }
    
    func setupSettingVariables() {
        username = appConfig.username
        amputationDate = appConfig.amputationDate
        prosthesisDate = appConfig.prosthesisDate
        targetSteps = appConfig.targetSteps
    }
    
    func checkSetupSheet(_ devType: devType) {
        if devType == .dev {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isSetupSheet = true
            }
        } else {
            let user = AppConfig.shared.username == "" ? true : false
            let amputationDate = Calendar.current.isDateInToday(appConfig.amputationDate)
            let prosthesisDate = Calendar.current.isDateInToday(appConfig.prosthesisDate)
            
            if user && amputationDate && prosthesisDate ? true : false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isSetupSheet = true
                }
            }
        }
    }
}



struct ReportOverlayView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @FetchRequest var allReports: FetchedResults<Report>
    
    @AppStorage("showReportSheet", store: AppConfig.store) var showReportSheet = false
    
    @State var stepsTotal = 0
    @State var distanceTotal = 0
    @State var wearingTimeTotal = 0
    
    
    @State var stepsTotalLastWeek = 0
    @State var distanceTotalLastWeek = 0
    @State var wearingTimeTotalLastWeek = 0
    
    init() {
        _allReports = FetchRequest<Report>(
            sortDescriptors: []
        )
    }
    
    var lastReport: Report? {
        self.allReports.last ?? nil
    }
    
    var body: some View {
        if showReportSheet {
            currentTheme.textBlack.opacity(0.7).ignoresSafeArea()
            
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    
                    HStack {
                        Text("Weekly Report")
                            .font(.headline.bold())
                    }
                    .padding(15)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(15)
                
                    VStack(spacing: 15) {
                        
                        HStack(spacing: 25) {
                            Image("figure.prothese")
                                .font(.title3.bold())
                     
                            VStack(alignment: .leading) {
                                Text("\( stepsTotal ) Steps")
                                    .font(.footnote.bold())
                                    .foregroundColor(currentTheme.text)
                                
                                Text("⌀ Steps")
                                    .font(.caption2)
                                    .foregroundColor(currentTheme.textGray)
                            }
                            
                            Spacer()
                        }
                        .padding(15)
                        .background(Material.ultraThinMaterial.opacity(0.7))
                        .cornerRadius(20)
                        .padding(5)
                        
                        HStack(spacing: 25) {
                            Image("prothese.below")
                                .font(.title3.bold())
                                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                            
                            VStack(alignment: .leading) {
                                let (h,m,_) = Int(wearingTimeTotal).secondsToHoursMinutesSeconds
                                Text("\(h) hrs. \(m) mins.")
                                    .font(.footnote.bold())
                                    .foregroundColor(currentTheme.text)
                                
                                Text("Total Wearingtime")
                                    .font(.caption2)
                                    .foregroundColor(currentTheme.textGray)
                            }
                            
                            Spacer()
                        }
                        .padding(15)
                        .background(Material.ultraThinMaterial.opacity(1))
                        .cornerRadius(20)
                        .padding(5)
                        
                        HStack(spacing: 25) {
                            Image("prothese.below")
                                .font(.title3.bold())
                                .flipHorizontal()
                            
                            VStack(alignment: .leading) {
                                let (h,m,_) = Int(wearingTimeTotal / 7).secondsToHoursMinutesSeconds
                                Text("\(h) hrs. \(m) mins.")
                                    .font(.footnote.bold())
                                    .foregroundColor(currentTheme.text)
                                
                                Text("⌀ Wearingtime")
                                    .font(.footnote)
                                    .foregroundColor(currentTheme.textGray)
                            }
                            
                            Spacer()
                        }
                        .padding(15)
                        .background(Material.ultraThinMaterial.opacity(0.7))
                        .cornerRadius(20)
                        .padding(5)
                        
                        HStack(spacing: 25) {
                            Image("distance")
                                .font(.title3.bold())
                            
                            VStack(alignment: .leading) {
                                Text("\(String(format: "%.2f", Double(distanceTotal) / 1000 )) km")
                                    .font(.footnote.bold())
                                
                                Text("Total Distance")
                                    .font(.footnote)
                                    .foregroundColor(currentTheme.textGray)
                            }
                            
                            Spacer()
                        }
                        .padding(15)
                        .background(Material.ultraThinMaterial.opacity(1))
                        .cornerRadius(20)
                        .padding(5)
                        
                        
                        HStack(spacing: 25) {
                            Spacer()

                            Button(action: {
                                withAnimation(.easeInOut) {
                                    showReportSheet = false
                                }
                            }, label: {
                                Text("Done!")
                                    .foregroundColor(currentTheme.hightlightColor)
                            })
                            
                            Spacer()
                        }
                        .padding(15)
                        .background(Material.ultraThinMaterial.opacity(1))
                        .cornerRadius(20)
                        .padding(5)
                    }
                    .padding(20)
                    .padding(.vertical, 10)
                }
                .background(Material.ultraThinMaterial.opacity(1))
                .cornerRadius(25)
                .padding(25)

                Spacer()
            }
            .onAppear {
                if let report = allReports.last {
                    loadData(start: report.startOfWeek ?? Date(), end: report.endOfWeek ?? Date())

                    let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: report.startOfWeek!)!.startEndOfWeek
                    
                    loadLastWeekData(start: lastWeek.start, end: lastWeek.end)
                }
            }
        }
    }
    
    private func loadData(start: Date, end: Date) {
        let week =  DateInterval(start: start, end: end)
        
        HealthStoreProvider().queryWeekCountbyType(week: week, type: .stepCount, completion: { stepCount in
            DispatchQueue.main.async {
                stepsTotal = stepCount.data.map { Int($0.value) }.reduce(0, +)
            }
        })
        
        // Total DistanzesSteps
        HealthStoreProvider().queryWeekCountbyType(week: week, type: .distanceWalkingRunning, completion: { distanceCount in
            DispatchQueue.main.async {
                distanceTotal = distanceCount.data.map { Int($0.value) }.reduce(0, +)
            }
        })
        
        // Total WearingTimes
        HealthStoreProvider().getWorkouts(week: week, workout: .default()) { workouts in
            DispatchQueue.main.async {
                let totalWorkouts = workouts.data.map({ workout in
                    return Int(workout.value)
                }).reduce(0, +)
                
                wearingTimeTotal = totalWorkouts
            }
        }
    }
    
    private func loadLastWeekData(start: Date, end: Date) {
        let week =  DateInterval(start: start, end: end)
        
        HealthStoreProvider().queryWeekCountbyType(week: week, type: .stepCount, completion: { stepCount in
            DispatchQueue.main.async {
                stepsTotalLastWeek = stepCount.data.map { Int($0.value) }.reduce(0, +)
            }
        })
        
        // Total DistanzesSteps
        HealthStoreProvider().queryWeekCountbyType(week: week, type: .distanceWalkingRunning, completion: { distanceCount in
            DispatchQueue.main.async {
                distanceTotalLastWeek = distanceCount.data.map { Int($0.value) }.reduce(0, +)
            }
        })
        
        // Total WearingTimes
        HealthStoreProvider().getWorkouts(week: week, workout: .default()) { workouts in
            DispatchQueue.main.async {
                let totalWorkouts = workouts.data.map({ workout in
                    return Int(workout.value)
                }).reduce(0, +)
                
                wearingTimeTotalLastWeek = totalWorkouts
            }
        }
    }
    
}

enum devType {
    case production, dev
}

