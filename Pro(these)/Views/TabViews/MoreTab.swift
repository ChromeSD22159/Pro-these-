//
//  MoreTab.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 21.09.23.
//

import SwiftUI
import StoreKit

struct MoreTab: View {
    @EnvironmentObject var appConfig: AppConfig
    @Environment(\.requestReview) var requestReview
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    
    @State var notes: [UNNotificationRequest] = []
    
    @State var openSetupSheetFromSettingsSheet: Bool = false
    
    @State var image: String =  "LaunchImage"
    
    // not in use
    @State private var isAuthenticating = false
    @State private var showDebugField = false
    @State private var password = ""

    var body: some View {
        
        NavigationView {
            ZStack {
                currentTheme.gradientBackground(nil).ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false, content: {
                    VStack(spacing: 10) {
                        Header(image: image)

                        EditArora()
                        
                        Settings()
                        
                        copyright(isAuthenticating: $isAuthenticating, showDebugField: $showDebugField, password: $password)
                            .padding(.vertical, 20)
                    }
                })
                .coordinateSpace(name: "SCROLL")
                .ignoresSafeArea(.container, edges: .vertical)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onChange(of: appConfig.PushNotificationGoodMorning) { state in
            if state == false {
                AppRemoveNotifications.removeNotifications(keyworks: ["MOOD_GOOD_MORNING"], notes: notes)
            }
        }
        .onChange(of: appConfig.PushNotificationComebackReminder) { state in
            if state == false {
                AppRemoveNotifications.removeNotifications(keyworks: ["COMEBACK_REMINDER"], notes: notes)
            }
        }
        .onChange(of: appConfig.PushNotificationDailyMoodRemembering) { state in
            if state == false {
                AppRemoveNotifications.removeNotifications(keyworks: ["MOOD_REMINDER"], notes: notes)
            }
        }
        .onAppear {
            loadNotifications()
        }
        
    }
    
   
    
    @ViewBuilder
    func Header(image: String) -> some View {
        GeometryReader { proxy in
            
            let minY = proxy.frame(in: .named("SCROLL")).minY
            let size = proxy.size
            let height = (size.height + minY)
            
            Rectangle()
                .fill(currentTheme.gradientBackground(nil))
                .frame(width: size.width, height: height, alignment: .top)
                .overlay(content: {
                    ZStack {
                        
                        FloatingClouds(blur: appConfig.AuroraBlur, speed: appConfig.AuroraSpeed, opacity: appConfig.AuroraOpacity)
                        
                        LinearGradient(
                            colors: [
                                .clear,
                                currentTheme.backgroundColor.opacity(0.8)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    
                    HeaderContent()
                    
                })
                .cornerRadius(20)
                .offset(y: -minY)
            
            /*
            ZStack {
                
                
                
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: height, alignment: .top)
                    .overlay(content: {
                        ZStack {
                            
                            FloatingClouds(blur: 1, speed: 0.2, opacity: 0.8)
                            
                            LinearGradient(
                                colors: [
                                    .clear,
                                    currentTheme.backgroundColor.opacity(0.8)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                        
                        HeaderContent()
                        
                    })
                    .cornerRadius(20)
                    .offset(y: -minY)
                
            }
            */
            
        }
        .frame(height: 250)
    }
    
    @ViewBuilder
    func HeaderContent() -> some View {
        VStack {
            Spacer()
            
            if AppConfig.shared.username != "" {
                Text("Hallo, \(AppConfig.shared.username).")
            } else {
                Text("Hey!")
            }
            
            
            Spacer()
        }
    }
    
    @ViewBuilder
    func EditArora() -> some View {
        HStack {
            HStack(spacing: 5) {
                Button("-") {
                    appConfig.AuroraOpacity -= 0.05
                }
                
                VStack {
                    Text(appConfig.AuroraOpacity.round(decimal: 2))
                    Text("OPACITY")
                }
                
                Button("+") {
                    appConfig.AuroraOpacity += 0.05
                }
            }
            
            Spacer()
            
            HStack(spacing: 5) {
                Button("-") {
                    appConfig.AuroraSpeed -= 0.05
                }
                
                VStack {
                    Text(appConfig.AuroraSpeed.round(decimal: 2))
                    Text("SPEED")
                }
                
                Button("+") {
                    appConfig.AuroraSpeed += 0.05
                }
            }
            
            Spacer()
            
            HStack(spacing: 5) {
                Button("-") {
                    appConfig.AuroraBlur -= 0.05
                }
                
                VStack {
                    Text(appConfig.AuroraBlur.round(decimal: 2))
                    Text("BLUR")
                }
                
                Button("+") {
                    appConfig.AuroraBlur += 0.05
                }
            }
        }
        .padding()
        .background(currentTheme.hightlightColor)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func Settings() -> some View {
        
        if !appConfig.hasPro {
            Button(action: {
                DispatchQueue.main.async {
                    tabManager.ishasProFeatureSheet = true
                    tabManager.isSettingSheet = false
                }
            }, label: {
                GetProCard()
            })
        }
        
        // MARK: - Personal Settings
        NavigateTo( {
            StackLink(systemIcon: "person.crop.circle", buttonText: "Personal Settings", foregroundColor: currentTheme.accentColor)
        }, {
            PersonalDeteilsView(titel: LocalizedStringKey("Personal Settings"), username: appConfig.$username, amputationDate: appConfig.$amputationDate, prosthesisDate: appConfig.$prosthesisDate, targetSteps: appConfig.$targetSteps)
        }, from: .ignore)
        
        // MARK: - Mapped Settings
        ForEach(Pro_these_.Settings.items, id: \.id) { setting in

            NavigateTo( {
                StackLink(systemIcon: setting.icon, buttonText: setting.titel, foregroundColor: currentTheme.accentColor)
            }, {
                SettingsDeteilsView(titel: setting.titel, Options: setting.options)
            }, from: .ignore)
            
        }
        
        // MARK: - More Settings
        NavigateTo( {
            // List Preview
            StackLink(systemIcon: "ellipsis", buttonText: LocalizedStringKey("More settings"), foregroundColor: currentTheme.accentColor)
        }, {
            // List Detail
            MoreDeteilsView(titel: LocalizedStringKey("More settings"))
        }, from: .ignore)
        
        // MARK: - Manage Prostheses and Liners
        NavigateTo( {
            // List Preview
            StackLink(customIcon: "prothese.above", flipIcon: true, buttonText: LocalizedStringKey("Manage Prostheses and Liners"), foregroundColor: currentTheme.accentColor)
        }, {
            // List Detail
            LinerOverview()
        }, from: .ignore)
        
        // MARK: - Review
        HStack {
            Button(action: {
                requestReview()
            }, label: {
                HStack(spacing: 10){
                    VStack {
                        Image(systemName: "star.bubble")
                            .frame(width: 20, height: 20)
                            .foregroundColor(currentTheme.text)
                    }
                    .padding(6)
                    .background(currentTheme.text.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(currentTheme.text, lineWidth: 1)
                            
                    )
                    
                    Text("Rate the app")
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .foregroundColor(currentTheme.text)
                .background(currentTheme.primary.opacity(0.5))
                .overlay(
                       RoundedRectangle(cornerRadius: 10)
                       .stroke(lineWidth: 2)
                       .stroke(currentTheme.text.opacity(0.05))
               )
                .cornerRadius(10)
            })
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        
        // MARK: - Verbesserungsvorschlag
        if appConfig.hasProduct.hasProduct(.developer) {
            WebSheetButton(titel: "Suggestion for improvement", image: "questionmark.bubble", link: "https://www.prothese.pro/verbesserungsvorschlag/", color: currentTheme.primary, disable: false)
                .padding(.horizontal, 20)
        }
        
    }
    
    @ViewBuilder
    func Link(buttonText: String, foregroundColor: Color) -> some View {
        HStack {
            HStack{
                Text(buttonText)
                    .foregroundColor(foregroundColor)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(currentTheme.labelBackground(nil))
            .overlay(
                   RoundedRectangle(cornerRadius: 10)
                   .stroke(lineWidth: 2)
                   .stroke(foregroundColor)
           )
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 50)
    }
    
    @ViewBuilder
    func StackLink(systemIcon: String? = nil, customIcon: String? = nil, flipIcon: Bool? = false, buttonText: LocalizedStringKey, foregroundColor: Color) -> some View {
        let flip = flipIcon ?? false
        
        HStack {
            HStack(spacing: 10){
                VStack(){
                    if systemIcon != nil {
                        Image(systemName: systemIcon!)
                            .frame(width: 20, height: 20)
                            .foregroundColor(currentTheme.text)
                    }
                    
                    if customIcon != nil {
                        Image(customIcon!)
                            .frame(width: 20, height: 20)
                            .foregroundColor(currentTheme.text)
                            .scaleEffect(x: flip ? -1 : 0, y: flip ? 1 : 0)
                    }
                }
                .padding(6)
                .background(currentTheme.text.opacity(0.1))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(currentTheme.text, lineWidth: 1)
                        
                )
                
                Text(buttonText)
                    .multilineTextAlignment(.leading)
                    
                Spacer()
                
                Image(systemName: "chevron.right")
                    .frame(width: 20, height: 20)
                    .foregroundColor(currentTheme.text)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .foregroundColor(currentTheme.text)
            .background(currentTheme.primary.opacity(0.5))
            .overlay(
                   RoundedRectangle(cornerRadius: 10)
                   .stroke(lineWidth: 2)
                   .stroke(currentTheme.text.opacity(0.05))
           )
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    func GetProCard() -> some View {
        HStack(alignment: .center, spacing: 20) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
            
            VStack {
                HStack {
                    Text("Even more functions")
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                }
                
                HStack {
                    Text("Update to unlock all Pro functionality")
                        .font(.footnote)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .foregroundColor(currentTheme == Theme.orange ? currentTheme.text : currentTheme.primary)
        .padding(.vertical, 6)
        .padding(.horizontal)
        .background(currentTheme.hightlightColor.gradient)
        .cornerRadius(10)
        .padding(.horizontal, 20)
    }
    
    func loadNotifications() {
        PushNotificationManager().getAllPendingNotifications(debug: false) { note in
            DispatchQueue.main.async {
                notes.append(note)
            }
        }
    }
}

extension Double {
    func round(decimal: Int) -> String {
        return String(format: "%." + String(decimal) + "f", self)
    }
}

#Preview {
    MoreTab()
}
