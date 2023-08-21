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
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @State private var isPresentWebView = false
    
    @State var link: URL = URL(string: "https://prothese.pro/datenschutz/")!
    
    let testProducts: [LocalizedStringKey] = [LocalizedStringKey("Try it for 7 days for free"), LocalizedStringKey("1,99€ - Monthly"), LocalizedStringKey("19,99€ - Yearly")]

    var body: some View {
        ZStack {
    
            VStack {
                
                SheetHeader(title: "Get your premium subscription!", action: {
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
                                    Text("ProFeature and ProWidgets")
                                        .font(.title.bold())
                                        .foregroundColor(currentTheme.text)
                                    
                                    Text("With an upgrade to the premium version, the app gets even better!")
                                        .foregroundColor(currentTheme.text)
                                        .font(.callout)
                                        .multilineTextAlignment(.center)
                                }
                                
                                // List Content
                                VStack(alignment: .leading, spacing: 12){
                                    Label("Manage unlimited contacts", systemImage: "checkmark.seal.fill")
                                    Label("More premium widgets", systemImage: "checkmark.seal.fill")
                                    Label("Premium statistics", systemImage: "checkmark.seal.fill")
                                    Label("Premium support for users", systemImage: "checkmark.seal.fill")
                                    Label("Participation in further development", systemImage: "checkmark.seal.fill")
                                    Label("100% ad-free", systemImage: "checkmark.seal.fill")
                                }
                                .foregroundColor(currentTheme.text)
                                .font(.callout)
                                
                                VStack(alignment: .center, spacing: 12){
                                    Text("Premium options")
                                        .font(.title3.bold())
                                        .foregroundColor(currentTheme.text)
                                    
                                    ForEach(purchaseManager.products.sorted(by: { $0.price < $1.price })) { (product) in
                                        Button {
                                            Task {
                                                do {
                                                    try await purchaseManager.purchase(product)
                                                } catch {
                                                    print(error)
                                                }
                                            }
                                        } label: {
                                            VStack(spacing: 5) {
                                                HStack {
                                                    Text("\(product.displayPrice)")
                                                        .font(.title2.bold())
                                                        .foregroundColor(currentTheme.text)
                                                    
                                                    Spacer()
                                                    Text("\(product.displayName)")
                                                        .foregroundColor(currentTheme.text)
                                                }
                                                
                                                HStack {
                                                    Spacer()
                                                    Text("\(product.description)")
                                                        .foregroundColor(currentTheme.textGray)
                                                        .font(.caption2)
                                                }
                                            }
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
                                        Text("Restore")
                                            .foregroundColor(currentTheme.text)
                                    }
                                    .padding(.top)
                                    
                                    HStack {
                                      Text("Auto Renewal. Cancellable at any time.")
                                            .foregroundColor(currentTheme.text)
                                            .font(.caption2)
                                    }
                                    
                                    HStack {
                                        Button("data protection") {
                                            // 2
                                            isPresentWebView = true
                                            link = URL(string: "https://prothese.pro/datenschutz/")!
                                        }
                                        .foregroundColor(currentTheme.text)
                                        .font(.caption2)
                                        
                                        Button("Terms of Use") {
                                            // 2
                                            isPresentWebView = true
                                            link = URL(string: "https://prothese.pro/nutzungsbedingungen/")!
                                        }
                                        .foregroundColor(currentTheme.text)
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
