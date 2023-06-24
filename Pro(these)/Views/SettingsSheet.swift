//
//  SettingsSheet.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 05.05.23.
//

import SwiftUI

struct SettingsSheet: View {
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var entitlementManager: EntitlementManager
    var body: some View {
        NavigationView {
            ZStack {
                appConfig.backgroundGradient
                    .ignoresSafeArea()
            
                VStack{
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            
                            Spacer()

                            VStack(alignment: .leading, spacing: 20){
                                
                                // MARK: - Personal Settings
                                NavigateTo( {
                                    StackLink(icon: "person.crop.circle", buttonText: "Persönliche Einstellungen", foregroundColor: appConfig.foreground)
                                }, {
                                    PersonalDeteilsView(titel: "Persönliche Einstellungen")
                                })
                                
                                // MARK: - Mapped Settings
                                ForEach(Settings.items, id: \.id) { setting in

                                    if setting.titel == "Sicherheit" && entitlementManager.hasPro {
                                        NavigateTo( {
                                            StackLink(icon: setting.icon, buttonText: setting.titel, foregroundColor: appConfig.foreground)
                                        }, {
                                            SettingsDeteilsView(titel: setting.titel, Options: setting.options)
                                        })
                                        .opacity(entitlementManager.hasPro ? 1 : 0)
                                    } else {
                                        NavigateTo( {
                                            StackLink(icon: setting.icon, buttonText: setting.titel, foregroundColor: appConfig.foreground)
                                        }, {
                                            SettingsDeteilsView(titel: setting.titel, Options: setting.options)
                                        })
                                    }
                                    
                                    
                                }
                                
                                // MARK: - More Settings
                                NavigateTo( {
                                    // List Preview
                                    StackLink(icon: "ellipsis", buttonText: "Mehr Einstellungen", foregroundColor: appConfig.foreground)
                                }, {
                                    // List Detail
                                    MoreDeteilsView(titel: "Mehr Einstellungen")
                                })
                                
                                HStack {
                                    Button("Setup Screen") {
                                        tabManager.isSettingSheet = false
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                            tabManager.isSetupSheet = true
                                        })
                                    }
                                    .foregroundColor(.white)
                                    .font(.callout)
                                    .padding(.horizontal)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity ,alignment: .leading)
                                .padding(.all, 15.0)
                                .frame(maxWidth: .infinity)
                                .background(AppConfig().background.opacity(0.5))
                                .cornerRadius(10)
                                .padding(.horizontal)
                                
                                Spacer()
                            }
                            .padding(.top, 25)
                            
                            
                            Spacer()
                            
                            copyright()
                        }
                        
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
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
            .background(AppConfig().backgroundLabel)
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
    func StackLink(icon: String, buttonText: String, foregroundColor: Color) -> some View {
        HStack {
            HStack(spacing: 10){
                VStack(){
                    Image(systemName: icon)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                }
                .padding(10)
                .background(.white.opacity(0.1))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.white, lineWidth: 2)
                        
                )
                
                Text(buttonText)
                    
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(AppConfig().backgroundLabel)
            .overlay(
                   RoundedRectangle(cornerRadius: 10)
                   .stroke(lineWidth: 2)
                   .stroke(.white.opacity(0.05))
           )
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
    
    
}

struct copyright: View {
    @EnvironmentObject var appConfig: AppConfig
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            HStack(alignment: .center, content: {
                Spacer()
                Text(appConfig.hasUnlockedPro ? "Pro Prothese APP v\(appVersion ?? "")" : "Prothese APP v\(appVersion ?? "")")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
                Spacer()
            })
            
            HStack(alignment: .center, content: {
                Spacer()
                Text("© Frederik Kohler \(Date().dateFormatte(date: "yyyy", time: "").date)")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Spacer()
            })
        }
    }
}

struct SettingsSheet_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppConfig.shared.background.ignoresSafeArea()
            
            VStack{
                SettingsSheet()
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

