//
//  MoreDeteilsView.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 21.06.23.
//

import SwiftUI

struct MoreDeteilsView: View {
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var titel: LocalizedStringKey

    @State var helpUs = [
        (id: 1, icon: "newspaper", titel: LocalizedStringKey("News"), url: "https://prothese.pro/", disable: false),
        (id: 2, icon: "questionmark.bubble", titel: LocalizedStringKey("Support"), url: "https://prothese.pro/kontakt/", disable: false),
        (id: 3, icon: "exclamationmark.bubble", titel: LocalizedStringKey("Recommend app"), url: "https://prothese.pro/datenschutz/", disable: true),
        (id: 4, icon: "info.bubble", titel: LocalizedStringKey("Data protection"), url: "https://prothese.pro/datenschutz/", disable: false),
        (id: 5, icon: "exclamationmark.bubble", titel: LocalizedStringKey("Terms of Use"), url: "https://prothese.pro/nutzungsbedingungen/", disable: false),
    ]
    
    var body: some View {
        ZStack {
            currentTheme.gradientBackground(nil)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10){
                    HStack{
                        Text(titel)
                            .foregroundColor(currentTheme.text)
                    }
                    .padding(.bottom)
                    
                    AboutUs()
                    
                    Spacer()
                    
                    copyright(isAuthenticating: .constant(false), showDebugField: .constant(false), password: .constant(""))
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
                 ForEach(helpUs, id: \.id) {_, icon, titel, url, disable in
                     
                     WebSheetButton(titel: titel, image: icon, link: url, color: currentTheme.primary, disable: disable)
                     
                 }
             },
             header: {
                 HStack{
                     Text("Support us")
                         .foregroundColor(currentTheme.textGray)
                         .font(.caption2)
                     Spacer()
                 }
             }
        )
    }
}

struct WebSheetButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    private var string: LocalizedStringKey
    
    private var image: String
    
    private var disable: Bool
    
    private var link: URL
    
    private var color: Color
    
    @State var isPresentWebView = false
    
    init(titel: LocalizedStringKey, image: String? = "text.viewfinder", link: String, color:Color, disable: Bool) {
        self.string = titel
        self.disable = disable
        self.link =  URL(string: link)!
        self.image = image!
        self.color = color
    }
    
    var body: some View {
        HStack {
            Button(action: {
                isPresentWebView.toggle()
            }, label: {
                HStack(spacing: 10){
                    VStack {
                        Image(systemName: image)
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
                    
                    Text(string)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .foregroundColor(currentTheme.text)
                .overlay(
                       RoundedRectangle(cornerRadius: 10)
                       .stroke(lineWidth: 2)
                       .stroke(currentTheme.text.opacity(0.05))
               )
                .cornerRadius(10)
            })
            .foregroundColor(disable ? currentTheme.textGray : currentTheme.text)
            .font(.callout)
            .disabled(disable)
            
            Spacer()
        }
        .frame(maxWidth: .infinity ,alignment: .leading)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.5))
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
            Theme.blue.gradientBackground(nil).ignoresSafeArea()
            
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
