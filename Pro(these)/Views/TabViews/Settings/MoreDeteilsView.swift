//
//  MoreDeteilsView.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 21.06.23.
//

import SwiftUI

struct MoreDeteilsView: View {
    @EnvironmentObject var appConfig: AppConfig
    
    var titel: String
    
    
    
    @State var helpUs = [
        (titel: "Neuigkeiten", url: "https://prothese.pro/", disable: false),
        (titel: "Support", url: "https://prothese.pro/kontakt/", disable: false),
        (titel: "Bewertungen", url: "https://prothese.pro/datenschutz/", disable: true),
        (titel: "App weiterempfehlen", url: "https://prothese.pro/datenschutz/", disable: true),
        (titel: "Datenschutz", url: "https://prothese.pro/datenschutz/", disable: false),
        (titel: "Nutzungsbedingungen", url: "https://prothese.pro/nutzungsbedingungen/", disable: false),
    ]
    
    var body: some View {
        ZStack {
            AppConfig().backgroundGradient
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20){
                    HStack{
                        Text(titel)
                            .foregroundColor(.white)
                    }
                    
                    AboutUs()
                    
                    Spacer()
                    
                    copyright()
                }
                .padding(.top, 80)
                
            }
            .ignoresSafeArea()
            .padding(.horizontal)
        }
        
        
    }
    
    @ViewBuilder
    func AboutUs() -> some View {
        Section(
             content: {
                 ForEach(helpUs, id: \.titel) { titel, url, disable in
                     
                     WebSheetButton(titel, link: url, disable: disable)
                     
                 }
             },
             header: {
                 HStack{
                     Text("Unterstütze Uns")
                         .foregroundColor(.gray)
                         .font(.caption2)
                     Spacer()
                 }
             }
        )
    }
}

struct WebSheetButton: View {
    
    private var string: String
    
    private var disable: Bool
    
    private var link: URL
    
    @State var isPresentWebView = false
    
    init<Title>(_ string: Title, link: String, disable: Bool) where Title : StringProtocol {
        self.string = string as! String
        self.disable = disable
        self.link =  URL(string: link)!
    }
    
    var body: some View {
        HStack {
            Button(string) {
                isPresentWebView.toggle()
            }
            .foregroundColor(disable ? .gray : .white)
            .font(.callout)
            .padding(.horizontal)
            .disabled(disable)
            
            Spacer()
        }
        .frame(maxWidth: .infinity ,alignment: .leading)
        .padding(.all, 15.0)
        .frame(maxWidth: .infinity)
        .background(AppConfig().background.opacity(0.5))
        .cornerRadius(10)
        .blurredSheet(.init(.ultraThinMaterial), show: $isPresentWebView, onDismiss: {}, content: {
            NavigationStack {
                // 3
                WebView(url: link)
                    .ignoresSafeArea()
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        })
    }
}

struct MoreDeteilsView_Previews: PreviewProvider {
    static var previews: some View {
       
        ZStack {
            AppConfig.shared.background.ignoresSafeArea()
            
            VStack{
                MoreDeteilsView(titel: "Titel")
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
