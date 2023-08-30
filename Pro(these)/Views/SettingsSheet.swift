//
//  SettingsSheet.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 05.05.23.
//

import SwiftUI
import StoreKit

struct SettingsSheet: View {
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var entitlementManager: EntitlementManager
    @Environment(\.requestReview) var requestReview
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @State private var isAuthenticating = false
    @State private var showDebugField = false
    @State private var password = ""
    
    @State var notes: [UNNotificationRequest] = []
    
    @Binding var username: String
    
    @Binding var amputationDate: Date
    
    @Binding var prosthesisDate: Date
    
    @Binding var openSetupSheetFromSettingsSheet: Bool
    
    @Binding var targetSteps: Int
    
    var body: some View {
        NavigationView {
            ZStack {
                currentTheme.gradientBackground(nil).ignoresSafeArea()
                
                VStack{
                    
                    SheetHeader(title: "Settings", action: {
                        tabManager.isSettingSheet.toggle()
                    })
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {

                            VStack(alignment: .leading, spacing: 10){
                                
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
                                    PersonalDeteilsView(titel: LocalizedStringKey("Personal Settings"), username: $username, amputationDate: $amputationDate, prosthesisDate: $prosthesisDate, targetSteps: $targetSteps)
                                })
                                
                                // MARK: - Mapped Settings
                                ForEach(Settings.items, id: \.id) { setting in

                                    NavigateTo( {
                                        StackLink(systemIcon: setting.icon, buttonText: setting.titel, foregroundColor: currentTheme.accentColor)
                                    }, {
                                        SettingsDeteilsView(titel: setting.titel, Options: setting.options)
                                    })
                                    
                                }
                                
                                // MARK: - More Settings
                                NavigateTo( {
                                    // List Preview
                                    StackLink(systemIcon: "ellipsis", buttonText: LocalizedStringKey("More settings"), foregroundColor: currentTheme.accentColor)
                                }, {
                                    // List Detail
                                    MoreDeteilsView(titel: LocalizedStringKey("More settings"))
                                })
                                
                                // MARK: - Manage Prostheses and Liners
                                NavigateTo( {
                                    // List Preview
                                    StackLink(customIcon: "prothese.above", flipIcon: true, buttonText: LocalizedStringKey("Manage Prostheses and Liners"), foregroundColor: currentTheme.accentColor)
                                }, {
                                    // List Detail
                                    LinerOverview()
                                })
                                
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
                                
                                // MARK: - Einrichtung
                                HStack {
                                    Button(action: {
                                        openSetupSheetFromSettingsSheet = true
                                        tabManager.isSettingSheet = false
                                    }, label: {
                                        HStack(spacing: 10){
                                            VStack {
                                                Image(systemName: "slider.horizontal.3")
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
                                            
                                            Text(LocalizedStringKey("Setup Assistant"))
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
                                
                                Group {
                                    if appConfig.adsDebug {
                                        Button(action: {
                                            isAuthenticating.toggle()
                                        }, label: {
                                            HStack {
                                                HStack(spacing: 10){
                                                    VStack {
                                                        Image(systemName: "slider.horizontal.3")
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
                                                    
                                                    Text(LocalizedStringKey("System"))
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
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.horizontal, 20)
                                        })
                                        .alert("Log in", isPresented: $isAuthenticating) {
                                            SecureField("Password", text: $password)
                                            Button("OK", action: authenticate)
                                            Button("Cancel", role: .cancel) { }
                                        } message: {
                                            Text("Please enter your username and password.")
                                        }
                                    }

                                    if showDebugField {
                                        // MARK: - SYSTEMCHECK
                                        NavigateTo({
                                            HStack {
                                                HStack(spacing: 10){
                                                    VStack {
                                                        Image(systemName: "slider.horizontal.3")
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
                                                    
                                                    Text(LocalizedStringKey("Debug"))
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
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.horizontal, 20)
                                        }, {
                                            SystemDebugDataView(titel: "Debug")
                                        })
                                    }
                                   
                                    
                                }
                                //.show(appConfig.adsDebug)
                                
                                Spacer()
                            }
                            .padding(.top, 25)
                            
                            
                            Spacer()
                            
                            copyright(isAuthenticating: $isAuthenticating, showDebugField: $showDebugField, password: $password)
                        }
                        
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear {
            loadNotifications()
        }
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
        
    }

    func loadNotifications() {
        PushNotificationManager().getAllPendingNotifications(debug: false) { note in
            DispatchQueue.main.async {
                notes.append(note)
            }
        }
    }
    
    func authenticate() {
        if password == AppConfig.shared.debugPW {
               showDebugField = true
           } else {
               showDebugField = false
           }
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
    
    
}

struct copyright: View {
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    @Binding var isAuthenticating: Bool
    
    @Binding var showDebugField: Bool
    
    @Binding var password: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            
            
            Button(action: {
                isAuthenticating.toggle()
            }, label: {
                HStack(alignment: .center, content: {
                    Spacer()
                    Text(appConfig.hasUnlockedPro ? "Pro Prothese APP v\(appVersion ?? "")" : "Prothese APP v\(appVersion ?? "")")
                        .font(.caption.bold())
                        .foregroundColor(currentTheme.textGray)
                    Spacer()
                })
            })
            .alert("Log in", isPresented: $isAuthenticating) {
                SecureField("Password", text: $password)
                Button("OK", action: authenticate)
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Please enter your username and password.")
            }
            
            HStack(alignment: .center, content: {
                Spacer()
                Text("© Frederik Kohler \(Date().dateFormatte(date: "yyyy", time: "").date)")
                    .font(.caption2)
                    .foregroundColor(currentTheme.textGray)
                Spacer()
            })
        }
    }
    
    func authenticate() {
        if password == AppConfig.shared.debugPW {
               showDebugField = true
           } else {
               showDebugField = false
           }
    }
}

struct SettingsSheet_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Theme.blue.gradientBackground(nil).ignoresSafeArea()
            
            VStack{
                SettingsSheet(username: .constant("test"), amputationDate: .constant(Date()), prosthesisDate: .constant(Date()), openSetupSheetFromSettingsSheet: .constant(false), targetSteps: .constant(10000))
                    .environmentObject(AppConfig())
                    .environmentObject(TabManager())
                    .environmentObject(HealthStorage())
                    .environmentObject(PushNotificationManager())
                    .environmentObject(EventManager())
                    .environmentObject(MoodCalendar())
                    .environmentObject(WorkoutStatisticViewModel())
                    .environmentObject(PainViewModel())
                    .environmentObject(StateManager())
                    .environmentObject(EntitlementManager())
                    .defaultAppStorage(UserDefaults(suiteName: "group.FK.Pro-these-")!)
                    .colorScheme(.dark)
            }
        }
    }
}


