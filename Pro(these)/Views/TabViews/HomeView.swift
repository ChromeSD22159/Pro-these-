//
//  HomeView.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 27.04.23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var entitlementManager: EntitlementManager
    
    var body: some View {
        VStack(spacing: 20){
            
            header()
            
            ScrollView(showsIndicators: false) {
                
                VStack(alignment: .center, spacing: 20){
                    Image("GetProProthesePNG")
                        .resizable()
                        .scaledToFit()
                        .tag("V1")
                        .padding(.horizontal)
                    
                    Text("ProFeature und ProWidgets")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    
                    Text("Mit einem Upgrade auf die Premium- \n Version wird die App noch besser!")
                        .foregroundColor(.white)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                    
                    if !entitlementManager.hasPro {
                        Button("Hol dir dein Premium Abo!") {
                            tabManager.ishasProFeatureSheet.toggle()
                        }
                        .padding(6)
                        .frame(maxWidth: .infinity)
                        .background(.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(20)
                    } else {
                        Button("Du hast das Premium Abo!") {
                            tabManager.ishasProFeatureSheet.toggle()
                        }
                        .padding(6)
                        .frame(maxWidth: .infinity)
                        .background(.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(20)
                        .disabled(true)
                    }
                    
                }
                .foregroundColor(.white)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
            }
            
        }
    }
        
    @ViewBuilder
    func header() -> some View {
        HStack(){
            VStack(spacing: 2){
                sayHallo(name: appConfig.username)
                    .font(.title2)
                    .foregroundColor(appConfig.fontColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Deine Termine und Notizen im Überblick.")
                    .font(.callout)
                    .foregroundColor(appConfig.fontLight)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack(spacing: 20){
                if !entitlementManager.hasPro {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(AppConfig.shared.fontColor)
                        .onTapGesture {
                            DispatchQueue.main.async {
                                tabManager.ishasProFeatureSheet.toggle()
                            }
                        }
                }
                
                Image(systemName: "gearshape")
                    .foregroundColor(AppConfig.shared.fontColor)
                    .font(.title3)
                    .onTapGesture {
                        tabManager.isSettingSheet.toggle()
                    }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .frame(maxWidth: .infinity)
    }
    
    func sayHallo(name: String) -> some View {
        let hour = Calendar.current.component(.hour, from: Date())
        
        var string = ""
        
        switch hour {
            case 6..<12 : string = "Guten Morgen, \(name)!"
            case 12 : string = "Guten Tag, \(name)!"
            case 13..<17 :  string = "Hallo \(name)!"
            case 17..<22 : string = "Guten Abend, \(name)!"
            default: string = "Hallo, \(name)!"
        }
        
        return Text(string)
    }
    
}

struct ScrollItem: Identifiable {
    var id: String { titel }
    let titel: String
    var bg: Color
    
    static let sampleItems = [
        ScrollItem(titel: "asd", bg: .red),
        ScrollItem(titel: "eer", bg: .orange),
    ]
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppConfig.shared.background.ignoresSafeArea()
            
            VStack{
                HomeView()
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

