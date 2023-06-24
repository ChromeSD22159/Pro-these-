//
//  ProFeatureSheet.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 20.06.23.
//

import SwiftUI
import MapKit
import WebKit
import StoreKit

struct ProFeatureSheet: View {
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject var entitlementManager: EntitlementManager

    @State private var isPresentWebView = false
    
    @State var link: URL = URL(string: "https://prothese.pro/datenschutz/")!
    
    let testProducts: [String] = ["Kostenlos 7 Tage testen", "1,99€ - Monatlich", "19,99€ - Jährlich"]
    
    var body: some View {
        ZStack {
    
            VStack {
                
                SheetHeader("Hol dir dein Premium Abo!", action: {
                    tabManager.ishasProFeatureSheet.toggle()
                })
                
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24){
                        TabView {
                            Image("ProWidgetPreview1")
                                .resizable()
                                .scaledToFit()
                                .tag("V1")
                                .padding(.horizontal)
                            
                            Image("ProWidgetPreview2")
                                .resizable()
                                .scaledToFit()
                                .tag("V2")
                                .padding(.horizontal)
                            
                            Image("ProWidgetPreview3")
                                .resizable()
                                .scaledToFit()
                                .tag("V3")
                                .padding(.horizontal)
                            
                            Image("ProWidgetPreview4")
                                .resizable()
                                .scaledToFit()
                                .tag("V4")
                                .padding(.horizontal)
                        }
                        .tabViewStyle(.page)
                        .frame(maxWidth: .infinity)
                        .frame(height: 250)
                        
                        // Hero Content
                        
                        HStack {
                            Spacer()
                            
                            VStack(spacing: 30) {
                                VStack(alignment: .center, spacing: 6){
                                    Text("ProFeature und ProWidgets")
                                        .font(.title.bold())
                                        .foregroundColor(.white)
                                    
                                    Text("Mit einem Upgrade auf die Premium- \n Version wird die App noch besser!")
                                        .foregroundColor(.white)
                                        .font(.callout)
                                        .multilineTextAlignment(.center)
                                }
                                
                                // List Content
                                VStack(alignment: .leading, spacing: 12){
                                    Label("Unbegrenzt Kontakten Verwalten", systemImage: "checkmark.seal.fill")
                                    Label("Mehr Premium Widgets", systemImage: "checkmark.seal.fill")
                                    Label("Premium Statistiken", systemImage: "checkmark.seal.fill")
                                    Label("Premium Support für Nutzer", systemImage: "checkmark.seal.fill")
                                    Label("Beteiligung an der Weiterentwicklung", systemImage: "checkmark.seal.fill")
                                    Label("100% Werbefrei", systemImage: "checkmark.seal.fill")
                                }
                                .foregroundColor(.white)
                                .font(.callout)
                                
                                VStack(alignment: .center, spacing: 12){
                                    Text("Premium Optionen")
                                        .font(.title3.bold())
                                        .foregroundColor(.white)
                                    
                                    ForEach(purchaseManager.products) { (product) in
                                        Button {
                                            Task {
                                                do {
                                                    try await purchaseManager.purchase(product)
                                                } catch {
                                                    print(error)
                                                }
                                            }
                                        } label: {
                                            Text("\(product.displayPrice) - \(product.displayName)")
                                                .foregroundColor(.white)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding()
                                        .background(Material.ultraThinMaterial)
                                        .cornerRadius(20)
                                    }
                                    
                                    Button {
                                        Task {
                                            do {
                                                try await AppStore.sync()
                                            } catch {
                                                print(error)
                                            }
                                        }
                                    } label: {
                                        Text("Wiederherstellen")
                                            .foregroundColor(.white)
                                    }
                                    .padding(.top)
                                    
                                    HStack {
                                        Button("Datenschutz") {
                                            // 2
                                            isPresentWebView = true
                                            link = URL(string: "https://prothese.pro/datenschutz/")!
                                        }
                                        .foregroundColor(.white)
                                        .font(.caption2)
                                        
                                        Button("Nutzungsbedingungen") {
                                            // 2
                                            isPresentWebView = true
                                            link = URL(string: "https://prothese.pro/nutzungsbedingungen/")!
                                        }
                                        .foregroundColor(.white)
                                        .font(.caption2)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .blurredSheet(.init(.ultraThinMaterial), show: $isPresentWebView, onDismiss: {}, content: {
                        NavigationStack {
                            // 3
                            WebView(url: link)
                                .ignoresSafeArea()
                        }
                    })
                }
                
            }
        }
    }
}

struct ProFeatureSheet_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            
            ProFeatureSheet()
                .environmentObject(TabManager())
                .environmentObject(PurchaseManager(entitlementManager: EntitlementManager()))
                .environmentObject(EntitlementManager())
        }
    }
}


struct WebView: UIViewRepresentable {
    // 1
    let url: URL
    // 2
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    // 3
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
