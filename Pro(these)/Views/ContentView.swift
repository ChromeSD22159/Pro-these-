//
//  ContentView.swift
//  Pro Prothese
//
//  Created by Frederik Kohler on 23.04.23.
//

import SwiftUI
import CoreData
import MapKit

struct ContentView: View {
    var loc:MKCoordinateRegion
    
    @State private var RecordViewRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 47.62369790077433, longitude: 8.22015741916841),
            latitudinalMeters: 750, longitudinalMeters: 750
    )
    
    @EnvironmentObject private var tabManager: TabManager
    @EnvironmentObject private var healthStore: HealthStorage
    @EnvironmentObject private var cal: MoodCalendar
    @EnvironmentObject var pain: PainViewModel
    @StateObject var stopWatchProvider = StopWatchProvider()
    
    @State var activeTab: Tab = .healthCenter
    @State var activeSubTab: SubTab = .event
    @State var overlay = false
    
    @State var showSubTab = false
    
    var body: some View {
        
        GeometryReader { proxy in
            NavigationView {
                ZStack {
                    // Background Darkblue
                    AppConfig.shared.background
                    
                    // Background Darkblue with transparent RadialGradient
                    AppConfig.shared.backgroundRadial
                        .ignoresSafeArea()
                    
                    // Background Circle Animation
                    CircleAnimationInBackground(delay: 1, duration: 2)
                        .opacity(0.2)
                        .ignoresSafeArea()
                    
                    // Map only Show when StopWatch View is Active
                    if activeTab == .stopWatch {
                        Map(coordinateRegion: $RecordViewRegion, showsUserLocation: true)
                        
                        // overlay
                        RadialGradient(gradient: Gradient(colors: [
                            Color(red: 5/255, green: 5/255, blue: 15/255).opacity(0.5),
                            Color(red: 5/255, green: 5/255, blue: 15/255) //Color(red: 32/255, green: 40/255, blue: 63/255).opacity(1)
                        ]), center: .center, startRadius: 50, endRadius: 300)
                            .ignoresSafeArea()
                    }
                    
                    // Content
                    VStack(){
                        switch activeTab {
                            case .event: Events().padding(.bottom, 10)
                            case .healthCenter: WorkOutEntryView().padding(.bottom, 10)
                            //case .feeling: FeelingView().padding(.bottom, 10)
                           
                            case .stopWatch: StopWatchView().padding(.bottom, 10)
                            case .add: FeelingView().padding(.bottom, 10)
                            case .pain: PainEntry().padding(.bottom, 10)
                        }
                        
                        Spacer(minLength: 70)
                    }
                    .foregroundColor(AppConfig().foreground)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    
                    // Navigation
                    VStack(){
                        if showSubTab {
                            ZStack{
                                Color.black.ignoresSafeArea().opacity(showSubTab ? 0.5 : 0)
                                AppConfig.shared.backgroundRadial.ignoresSafeArea().opacity(showSubTab ? 0.5 : 0)
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
                        TabStack(activeTab: $activeTab, activeSubTab: $activeSubTab, showSubTab: $showSubTab)
                            .frame(height: 70)
                    }
                    .foregroundColor(AppConfig().foreground)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    
                    // Header blur
                    HeaderBackgroundBlurTop()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        // Settings Sheet
        .blurredSheet(.init(.ultraThinMaterial), show: $tabManager.isSettingSheet, onDismiss: {}, content: {
            SettingsSheet()
        })
        // Deeplink from Widget
        .onOpenURL { url in
            // Handle this deep link URL
            handleWidgetDeepLink(url)
            doAction(url)
        }
        // Overlay
        .overlay(overlay ? Launch_Screen().opacity(1) : Launch_Screen().opacity(0), alignment: .topTrailing)
        // Set EntryView from User Settings
        .onAppear{
            activeTab = AppConfig().entrySite
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)) { _ in
            overlay.toggle()
           
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 ) {
                overlay.toggle()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)) { _ in
            overlay.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 ) {
                overlay.toggle()
            }
        }
    }
    
    func doAction(_ url: URL){
        if url.host == "feeling" {
            withAnimation(.easeInOut(duration: 0.3)){
                showSubTab = false
                activeTab = .healthCenter
                tabManager.workoutTab = .feelings
                cal.isCalendar = true
                cal.addFeelingDate = Date()
                cal.isFeelingSheet = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                cal.isFeelingSheet = true
                print("from feeling widget")
            }
            
            
        } else if url.host == "pain" {
            print("from pain widget")
            withAnimation(.easeInOut(duration: 0.3)){
                showSubTab = false
                activeTab = .pain
                pain.showList = true
                pain.addPainDate = Date()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                pain.showList = true
                pain.isPainAddSheet = true
            }
        } else if url.host == "stopWatch" {
            /*
             if stopWatchProvider.recorderState != .started {
                 stopWatchProvider.recorderState = .started
                 stopWatchProvider.startRecording()
             }
             */
            
            withAnimation(.easeInOut(duration: 0.3))   {
                showSubTab = false
                activeTab = .stopWatch
            }
        } else {
            activeTab = url.tabIdentifier ?? .healthCenter
        }
    }
    
    private func handleWidgetDeepLink(_ url: URL) {
            
            guard
                let scheme = url.scheme,
                let host = url.host else {
                // Invalid URL format
                return
            }
            
            guard scheme == "ProProthese" else {
                // The deep link is not trigger by widget
                return 
            }
            
            print(url)
        }
}
