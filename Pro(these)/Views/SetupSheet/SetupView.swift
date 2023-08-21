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
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var healthKit: HealthStoreProvider
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var location: LocationProvider
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @Environment(\.dismiss) private var dismiss
    
    @State var showLogo = true
    @State var index = 0
    @State var targetStepes = 10000
    @State var amputationDate = Date()
    @State var prosthesisDate = Date()
    @State var name = ""
    
    @State var healthKitAuth = false
    @State var CalendarAuth = false
    @State var LocationAuth = false
    @State var NotificationAuth = false
    @State var faceIDAuth = false
    
    @State var prostheses: [newProthesis] = []
    
    @State var nextButton = true
    var body: some View {
        ZStack {
            GeometryReader { geo in
                currentTheme.backgroundColor.ignoresSafeArea()
                
                CircleAnimationInBackground(delay: 1, duration: 2)
                    .opacity(0.2)
                    .ignoresSafeArea()
                
                TabView(selection: $index) {
                    
                    StartTab(index: 0)
                    
                    NameStack(index: 1)
                    
                    StepsStack(index: 2)
                    
                    AmputationDayStack(index: 3)
                    
                    Prothesis(index: 4)
                    
                    Liner(index: 5)
                    
                    Permisson(index: 6)
                    
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onAppear {
                    name = appConfig.username
                    amputationDate = appConfig.amputationDate
                    prosthesisDate = appConfig.prosthesisDate
                    targetStepes = appConfig.targetSteps
                }

            }
        }
    }
    
    @ViewBuilder
    func StartTab(index: Int) -> some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                }
                
                VStack(alignment: .center, spacing: 6){
                    Text(LocalizedStringKey("We'll help you set up the app!"))
                        .font(.title.bold())
                        .foregroundColor(currentTheme.text)
                        .multilineTextAlignment(.center)
                    
                    Text(LocalizedStringKey("Just two steps away."))
                        .foregroundColor(currentTheme.text)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // List Content
                VStack(alignment: .leading, spacing: 12){
                    Label(LocalizedStringKey("Your first name"), systemImage: "checkmark.seal.fill")
                    Label(LocalizedStringKey("Your step goal"), systemImage: "checkmark.seal.fill")
                    Label(LocalizedStringKey("Amputation day"), systemImage: "checkmark.seal.fill")
                    Label(LocalizedStringKey("First day with prosthesis."), systemImage: "checkmark.seal.fill")
                    Label(LocalizedStringKey("Add Prosthetics"), systemImage: "checkmark.seal.fill")
                    Label(LocalizedStringKey("Add Prosthetics liners"), systemImage: "checkmark.seal.fill")
                    Label(LocalizedStringKey("Access Permissions"), systemImage: "checkmark.seal.fill")
                }
                .foregroundColor(currentTheme.text)
                .font(.callout)
                
                Spacer()
            }
            .padding()
            .frame(maxHeight: 550)
            .padding()
            
            button(type: .getStarted)

            Spacer()
        }.tag(index)
    }
      
    @ViewBuilder
    func NameStack(index: Int) -> some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                }
                
                VStack(alignment: .center, spacing: 6){
                    Text(LocalizedStringKey("Hello...?!\nWhat may we call you? "))
                        .font(.title.bold())
                        .foregroundColor(currentTheme.text)
                        .multilineTextAlignment(.center)
                    
                    Text(LocalizedStringKey("Please enter your first name."))
                        .foregroundColor(currentTheme.textGray)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                HStack {
                    TextField(name == "" ? "Your first name" : name, text: $name)
                        .foregroundColor(name == "" ? currentTheme.textGray : currentTheme.text)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .overlay(
                   RoundedRectangle(cornerRadius: 20)
                       .stroke(Color.gray, lineWidth: 1)
               )
                
                Spacer()
            }
            .padding()
            .frame(maxHeight: 500)
            .padding()
            
            button(type: .next)

            Spacer()
        }.tag(index)
    }
    
    @ViewBuilder
    func StepsStack(index: Int) -> some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                }
                
                VStack(alignment: .center, spacing: 6){
                    Text(LocalizedStringKey("How many steps would you like to walk a day?"))
                        .font(.title.bold())
                        .foregroundColor(currentTheme.text)
                        .multilineTextAlignment(.center)
                    
                    Text(LocalizedStringKey("Compare your progress against your set goal."))
                        .foregroundColor(currentTheme.textGray)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button( action: {
                        targetStepes = targetStepes.reduceSteps
                    }, label: {
                        Text("-")
                            .font(.title.weight(.light))
                            .padding(10)
                    })
                    .foregroundColor(currentTheme.text)
                    
                    Spacer()
                    
                    VStack {
                        HStack {
                            Spacer()
                            Text("\(targetStepes)")
                                .font(.title.bold())
                                .foregroundColor(currentTheme.text)
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            Text(LocalizedStringKey("Steps"))
                                .font(.caption2.bold())
                                .foregroundColor(currentTheme.text)
                            Spacer()
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(100)
                    
                    Spacer()
                    
                    Button( action: {
                        targetStepes = targetStepes.maximizeSteps
                    }, label: {
                        Text("+")
                            .font(.title.weight(.light))
                            .padding(10)
                    })
                    .foregroundColor(currentTheme.text)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity ,alignment: .leading)
                .padding(.all, 12)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial.opacity(0.5))
                .cornerRadius(100)
                /*
                HStack(){
                   
                    Button("-", action: { targetStepes = targetStepes.reduceSteps })
                        .frame(width: 20, height: 20)
                        .padding(10)
                        .foregroundColor(currentTheme.text)
                        .background(currentTheme.text.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(currentTheme.text, lineWidth: 1.5)
                        )
                    
                    Spacer()
                    
                    Text(LocalizedStringKey("\(targetStepes) Steps"))
                        .font(.title.bold())
                        .foregroundColor(currentTheme.text)
                    
                    Spacer()
                    
                    Button("+", action: { targetStepes = targetStepes.maximizeSteps })
                        .frame(width: 20, height: 20)
                        .padding(10)
                        .foregroundColor(currentTheme.text)
                        .background(currentTheme.text.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(currentTheme.text, lineWidth: 1.5)
                        )
                }
                .frame(maxWidth: .infinity ,alignment: .leading)
                .padding(.all, 12)
                .frame(maxWidth: .infinity)
                .cornerRadius(10)
                */
                
                Spacer()

            }
            .padding()
            .frame(maxHeight: 500)
            .padding()
            
            button(type: .next)

            Spacer()
        }.tag(index)
    }
    
    @ViewBuilder
    func AmputationDayStack(index: Int) -> some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                }
                
                VStack(alignment: .center, spacing: 6){
                    Text(LocalizedStringKey("What date was\nyour amputation?"))
                        .font(.title.bold())
                        .foregroundColor(currentTheme.text)
                        .multilineTextAlignment(.center)
                    
                    Text("Your amputation date is required for your statistics.")
                        .foregroundColor(currentTheme.textGray)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                DatePicker(LocalizedStringKey("Amputation day."), selection: $amputationDate, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(currentTheme.text)
                    .cornerRadius(10)
                
                Spacer()
            }
            .padding()
            .frame(maxHeight: 500)
            .padding()
            
            button(type: .next)

            Spacer()
        }.tag(index)
    }
   
    @ViewBuilder
    func ProstheticsDayStack(index: Int) -> some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                }
                
                Text(LocalizedStringKey("On what date did you get your first prosthesis?"))
                    .font(.title.bold())
                    .foregroundColor(currentTheme.text)
                
                Spacer()
                
                DatePicker(LocalizedStringKey("prosthesis day."), selection: $prosthesisDate, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(currentTheme.text)
                    .cornerRadius(10)
                
                Spacer()
            }
            .padding()
            .frame(maxHeight: 500)
            .padding()
            
            button(type: .next)

            Spacer()
        }.tag(index)
    }
    
    @ViewBuilder
    func PreviewStack(index: Int) -> some View {
        VStack {
            Spacer()
            
            VStack(alignment: .center, spacing: 6){
                Text("Pro Prothese Setup")
                    .font(.title.bold())
                    .foregroundColor(currentTheme.text)
                
                HStack {
                    TextField(name == "" ? "Your first name" : name, text: $name)
                        .foregroundColor(name == "" ? currentTheme.textGray : currentTheme.text)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .overlay(
                   RoundedRectangle(cornerRadius: 20)
                       .stroke(Color.gray, lineWidth: 1)
               )
            }
            
            button(type: .getStarted)

            Spacer()
        }.tag(index)
    }
    
    @ViewBuilder
    func Prothesis(index: Int) -> some View {
        
        VStack {
            Spacer()
            
            VStack(alignment: .center, spacing: 6){
                ProthesisAddView(nextButton: $nextButton)
                
                Spacer()
            }
            .padding()
            .frame(maxHeight: 550)
            .padding()
            
            if nextButton {
                button(type: .next)
            }

            Spacer()
        }.tag(index)
    }
    
    func Liner(index: Int) -> some View {
        
        VStack {
            Spacer()
            
            VStack(alignment: .center, spacing: 6){
                LinerAddView(nextButton: $nextButton)
                
                Spacer()
            }
            .padding()
            .frame(maxHeight: 550)
            .padding()
            
            if nextButton {
                button(type: .end)
            }

            Spacer()
        }.tag(index)
    }
    
    @ViewBuilder
    func Permisson(index: Int) -> some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                HStack {

                    Spacer()
                }
                Spacer()
                
                VStack(alignment: .center, spacing: 6){
                    Text("System access")
                        .font(.title.bold())
                        .foregroundColor(currentTheme.text)
                    
                    Text("Required Permissions")
                        .foregroundColor(currentTheme.text)
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
                        text: "If no authorization window appears, all access can be granted under \"Settings > Prosthesis\".",
                        foreground: currentTheme.text,
                        visibility: true
                    )
                }
                .foregroundColor(currentTheme.text)
                .font(.callout)
                
                Spacer()
            }
            .padding()
            .frame(maxHeight: 400)
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(currentTheme.hightlightColor, lineWidth: 5)
            )
            .cornerRadius(20)
            .padding()
            .onAppear{
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
        }.tag(index)
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
                    appConfig.username = name
                    appConfig.amputationDate = amputationDate
                    appConfig.prosthesisDate = prosthesisDate
                    appConfig.targetSteps = targetStepes
                    
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
            Text(type.rawValue)
                .font(.body.bold())
                .foregroundColor(currentTheme.textBlack)
                .textCase(.uppercase)
        })
        .padding(.horizontal, 18)
        .padding(.vertical, 9)
        .background(currentTheme.hightlightColor)
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

enum getStartedButton: LocalizedStringKey {
    case getStarted = "Getting started"
    case next = "next"
    case end = "end"
    case finish = "done"
    
    func image() -> String {
        switch self {
        case .getStarted: return "background"
        case .next: return "background2"
        case .end: return "background2"
        case .finish: return "background2"
        }
    }
}
