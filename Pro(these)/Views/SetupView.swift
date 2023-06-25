//
//  SetupView.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 23.06.23.
//

import SwiftUI
import HealthKit
import EventKit
import CoreLocation

struct SetupView: View {
    
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var healthKit: HealthStoreProvider
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var location: LocationProvider
    
    @Environment(\.dismiss) private var dismiss
    
    @State var showLogo = true
    @State var index = 0
    @State var name = ""
    
    @State var healthKitAuth = false
    @State var CalendarAuth = false
    @State var LocationAuth = false
    @State var NotificationAuth = false
    @State var faceIDAuth = false
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                background(logo: showLogo, screenSize: geo.size)
                
                TabView(selection: $index) {
                    
                    StartTab()
                    
                    HealthTab()
                    
                    Permisson()
                    
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

            }
        }
        .onAppear{
            
        }
    }
    
    @ViewBuilder
    func StartTab() -> some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                HStack {
                    /* Text("Einrichtung der App")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .textCase(.uppercase) */
                    
                    Spacer()
                }
                Spacer()
                
                VStack(alignment: .center, spacing: 6){
                    Text("Pro Prothese Setup")
                        .font(.title.bold())
                        .foregroundColor(.white)
                    
                    Text("Nur zwei Schritte entfernt.")
                        .foregroundColor(.white)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                }
                
                // List Content
                VStack(alignment: .leading, spacing: 12){
                    Label("Dein Vorname", systemImage: "checkmark.seal.fill")
                    Label("Dein Schrittziel", systemImage: "checkmark.seal.fill")
                    Label("Zugriffberechtigungen", systemImage: "checkmark.seal.fill")
                }
                .foregroundColor(.white)
                .font(.callout)
                
                Spacer()
            }
            .padding()
            .frame(maxHeight: 400)
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.yellow, lineWidth: 5)
            )
            .cornerRadius(20)
            .padding()
            
            button(type: .getStarted)

            Spacer()
        }.tag(0)
    }
    
    @ViewBuilder
    func HealthTab() -> some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                HStack {
                    Text("Persönliche Daten")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                    
                    Spacer()
                }
                
                Spacer()
                
                // Name
                VStack {
                    HStack {
                        Text("Dein Vorname")
                            .foregroundColor(.white)
                    }
                    
                    
                    HStack {
                        TextField(appConfig.username == "" ? "Dein Vorname" : appConfig.username, text: $appConfig.username)
                            .foregroundColor(name == "" ? .gray : .white)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .overlay(
                       RoundedRectangle(cornerRadius: 20)
                           .stroke(Color.gray, lineWidth: 1)
                   )
                }
                
                // Steps
                HStack(alignment: .center, spacing: 6) {
                    Button("-", action: { reduceSteps(input: appConfig.targetSteps) })
                        .frame(width: 20, height: 20)
                        .padding()
                        .foregroundColor(.yellow)
                        .background(.white.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.yellow, lineWidth: 1.5)
                        )
                    
                    Spacer()
                    
                    VStack(alignment: .center){
                        Text("\(appConfig.targetSteps)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Label("Täglichen Schritte", image: "prothesis")
                            .font(.body)
                            .fontWeight(.regular)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button("+", action: { maximizeSteps(input: appConfig.targetSteps) })
                        .frame(width: 20, height: 20)
                        .padding()
                        .foregroundColor(.yellow)
                        .background(.white.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.yellow, lineWidth: 1.5)
                        )
                    
                }
                .padding(.all, 15.0)
                .frame(maxWidth: .infinity)
                .cornerRadius(10)
                
                Spacer()
            }
            .padding()
            .frame(maxHeight: 400)
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.yellow, lineWidth: 5)
            )
            .cornerRadius(20)
            .padding()
            
            button(type: .next)
            
            Spacer()
        }.tag(1)
    }
             
    @ViewBuilder
    func Permisson() -> some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                HStack {

                    Spacer()
                }
                Spacer()
                
                VStack(alignment: .center, spacing: 6){
                    Text("Systemzugriff")
                        .font(.title.bold())
                        .foregroundColor(.white)
                    
                    Text("Benötigte Berechtigungen")
                        .foregroundColor(.white)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                
                // List Content
                VStack(alignment: .leading, spacing: 12){
                    HStack{
                        Spacer()
                        Label("HealthKit", systemImage: "checkmark.seal.fill")
                            .opacity(healthKitAuth ? 1 : 0)
                        Spacer()
                    }
                   
                    HStack{
                        Spacer()
                        Label("GPS Location", systemImage: "checkmark.seal.fill")
                            .opacity(LocationAuth ? 1 : 0)
                        Spacer()
                    }
                    
                    
                    HStack{
                        Spacer()
                        Label("Calender", systemImage: "checkmark.seal.fill")
                            .opacity(CalendarAuth ? 1 : 0)
                        Spacer()
                    }
                    
                    HStack{
                        Spacer()
                        Label("Push Notification", systemImage: "checkmark.seal.fill")
                            .opacity(NotificationAuth ? 1 : 0)
                        Spacer()
                    }
                   
                    
                    InfomationField(
                        backgroundStyle: .ultraThinMaterial,
                        text: "Sollte keine Authorizirungsfenster erscheinen, können alle Zugriffe unter \"Einstellungen > Pro Prothese\" erteilt werden.",
                        foreground: .white,
                        visibility: true
                    )
                }
                .foregroundColor(.white)
                .font(.callout)
                
                Spacer()
            }
            .padding()
            .frame(maxHeight: 400)
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.yellow, lineWidth: 5)
            )
            .cornerRadius(20)
            .padding()
            .onAppear{
                /*HealthStoreProvider().authorizationStatus(completion: { state in
                    healthKitAuth = state
                }) */
                
                
                switch LocationProvider.shared.manager.authorizationStatus {
                    case .notDetermined:  LocationAuth = false
                    case .restricted: LocationAuth = false
                    case .denied: LocationAuth = false
                    case .authorizedAlways: LocationAuth = true
                    case .authorizedWhenInUse: LocationAuth = true
                    @unknown default:  LocationAuth = false
                }
                
                EKEventStore().requestAccess(to: .event, completion: { success, _  in
                    CalendarAuth = success
                })
                
                let center = UNUserNotificationCenter.current()
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in

                    NotificationAuth = granted
                    // Enable or disable features based on the authorization.
                }
            }
            
            button(type: .end)
            
            Spacer()
        }.tag(2)
    }
    
    @ViewBuilder
    func background(logo: Bool, screenSize: CGSize) -> some View {
        
        Image(index.getBG())
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
        
        VStack(alignment: .center, spacing: 20) {
            
            Spacer()
            
            HStack {
                Spacer()
                Image("AppLogoTransparent")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: screenSize.width / 1.5, height: 200, alignment: .center)
                    .opacity(logo ? 1 : 0)
                Spacer()
            }
            
        }
            
    }
    
    @ViewBuilder
    func button(type: getStartedButton) -> some View {
        Button(action: {
            withAnimation(.easeInOut) {
                showLogo = false

                if type == .end {
                    appConfig.isSetupSheet = false
                    dismiss()
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        withAnimation(.easeInOut) {
                            index += 1
                        }
                    })
                }
            }
        }, label: {
            Text("\(type.rawValue)")
                .font(.body.bold())
                .foregroundColor(.black)
                .textCase(.uppercase)
        })
        .padding(.horizontal, 18)
        .padding(.vertical, 9)
        .background(.yellow)
        .cornerRadius(20)
    }
}


extension SetupView {
    func reduceSteps(input: Int) {
        if appConfig.targetSteps >= 1500 {
            let newT = input - 500
            appConfig.targetSteps = newT
        }
    }
    
    func maximizeSteps(input: Int) {
        if appConfig.targetSteps <= 49500 {
            let newT = input + 500
            appConfig.targetSteps = newT
        }
    }
    
}

extension Int {
    func getBG() -> String {
        switch self {
        case 0: return "background"
        case 1: return "background2"
        case 2: return "background3"
        default: return "background"
        }
    }
}

struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            ZStack {
                Color.black.ignoresSafeArea()
            }
        }
        .sheet(isPresented: .constant(true), content: {
            SetupView()
                .environmentObject(AppConfig())
                .environmentObject(HealthStoreProvider())
                .environmentObject(TabManager())
                .colorScheme(.dark)
        })
            
    }
}

enum getStartedButton: String {
    case getStarted = "Loslegen"
    case next = "Weiter"
    case end = "ende"
    case finish = "Fertig"
    func image() -> String {
        switch self {
        case .getStarted: return "background"
        case .next: return "background2"
        case .end: return "background2"
        case .finish: return "background2"
        }
    }
}
