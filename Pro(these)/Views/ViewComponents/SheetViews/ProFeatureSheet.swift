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
                                    
                                    Text("With an upgrade to the premium version,\nthe app gets even better!")
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

struct ShopSheet: View {
    @Environment(\.requestReview) private var requestReview
    
    @EnvironmentObject private var purchaseManager: PurchaseManager
    
    @EnvironmentObject var entitlementManager: EntitlementManager
    
    private var currentTheme: Theme {
        return ThemeManager().currentTheme()
    }
    
    private var maxPrice: [Double] {
        var prices = purchaseManager.products.map({ product in
            if product.id == "102" {
                return (product.price as NSDecimalNumber).doubleValue * 12
            } else {
                return (product.price as NSDecimalNumber).doubleValue
            }
        })
        
        let _ = purchaseManager.products.map({ product in
            if product.id == "102" {
                prices.append((product.price as NSDecimalNumber).doubleValue)
            }
        })
        
        return prices
    }
    
    @State private var isPresentWebView = false
    
    @State var link: URL = URL(string: "https://prothese.pro/datenschutz/")!
    
    @Binding var isSheet: Bool
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false, content: {
            ZStack {
                
                currentTheme.gradientBackground(nil)
                
                VStack(spacing: 10) {
                    AnimatedHeader()
                    
                    PayButtons()
                    
                    ListFeatureList()
                    
                    Spacer()
                    
                    BackButton(false)
                    
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
                    
                    BottomLinks()
                        .padding(.bottom, 40)
                }
                .onAppear {
                    if AppStoreReviewRequest.requestReviewHandlerWithoutLimits {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                            requestReview()
                        })
                    }
                }
            }
        })
        .coordinateSpace(name: "SCROLL")
        .ignoresSafeArea(.container, edges: .vertical)
        .blurredSheet(.init(.ultraThinMaterial), show: $isPresentWebView, onDismiss: {}, content: {
            NavigationStack {
                // 3
                WebView(url: link)
                    .ignoresSafeArea()
            }
        })
    }
    
    @ViewBuilder func AnimatedHeader() -> some View {
        GeometryReader { proxy in
            
            let minY = proxy.frame(in: .named("SCROLL")).minY
            let size = proxy.size
            let height = (size.height + minY)
            
            Rectangle()
                .fill(currentTheme.gradientBackground(nil))
                .frame(width: size.width, height: height, alignment: .top)
                .overlay(content: {
                    ZStack {
                        
                        currentTheme.gradientBackground(nil)
                        
                        FloatingClouds(speed: 1.0, opacity: 0.8)
                        
                        LinearGradient(
                            colors: [
                                .clear,
                                currentTheme.backgroundColor
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    
                     AnimatedHeaderContent()
                        .blur(radius: abs(minY / 100 * 2))
                        .offset(y: minY.sign == .minus ? minY * 1.5 : 0)
                        //.opacity(calcOpacity(minY))
                    
                })
                .cornerRadius(20)
                .offset(y: -minY)
            
        }
        .frame(height: 250)
    }
    
    @ViewBuilder func AnimatedHeaderContent() -> some View {
        VStack {
            HStack {
                Spacer()
                
                Button(action: {
                    isSheet.toggle()
                }, label: {
                    Image(systemName: "xmark")
                        .font(.title)
                        .foregroundColor(currentTheme.text)
                        .padding(.top, 20)
                        .padding()
                })
            }
            .padding()
            
            VStack(alignment: .center, spacing: 6){
                Text("Premium membership")
                    .font(.title.bold())
                    .foregroundColor(currentTheme.text)
                
                Text("With an upgrade to the premium version,\nthe app gets even better!")
                    .foregroundColor(currentTheme.text)
                    .font(.callout)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    @ViewBuilder func PayButtons() -> some View {
        VStack {
            ForEach(purchaseManager.products.sorted(by: { $0.price < $1.price })) { product in
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

                        PaymentButtonLabel(
                            name: ProductNames(id: product.id),
                            save: product.id == "103" || product.id == "7777" ? (from: maxPrice.max() ?? 0.1 , to: (product.price as NSDecimalNumber).doubleValue) : nil,
                            price: product.displayPrice,
                            periode: ProductPeriode(id: product.id)
                        )
                        
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(Material.ultraThinMaterial)
                .cornerRadius(20)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder func PaymentButtonLabel(name: String, save: (from: Double, to: Double)? = nil, price: String, periode: String) -> some View {
           HStack {
               Text(name)
                   .font(.body.bold())
                   .foregroundColor(currentTheme.text)
           
               let savingPrice = calcSaving(max: save?.from ?? 0, current: save?.to ?? 0)
               Text("🎁 save \( (100 - savingPrice) )%").font(.caption2.bold())
                       .padding(.horizontal, 10)
                       .padding(.vertical, 5)
                       .foregroundColor(currentTheme.text)
                       .background{
                           RoundedRectangle(cornerRadius: 15)
                               .fill(currentTheme.hightlightColor.opacity(0.25))
                       }
                       .opacity(save == nil ? 0 : 1)
               
               
               Spacer()
               
               Text(price).font(.body.bold())
                   .foregroundColor(currentTheme.text)
               
               Text("/ " + periode).font(.footnote.bold())
                   .foregroundColor(currentTheme.text)
           }
           .padding(10)
           .cornerRadius(15)
       }
     
    @ViewBuilder func BottomLinks() -> some View {
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
        .padding(.horizontal)
    }
    
    @ViewBuilder func BackButton(_ bool: Bool) -> some View {
        if bool {
            Button(action: {
                isSheet.toggle()
            }, label: {
                HStack {
                    Spacer()
                    Text("Cancel")
                        .font(.body.bold())
                        .foregroundColor(currentTheme.text)
                    Spacer()
                }
                .padding()
                .background(Material.ultraThinMaterial)
                .cornerRadius(15)
                
            })
            .padding(.horizontal)
            
            
            
            Spacer()
        }
    }
    
    /* CALC */ private func calcSaving(max: Double, current: Double) -> Int {
            guard max + current != 0.0 else {
                return 0
            }
            
            return 100 / Int(max) * Int(current)
        }

    /* STRING */ private func ProductPeriode(id: String) -> String {
        switch id {
            case "102": return LocalizedStringKey("Month").localizedstring()
            case "7777": return LocalizedStringKey("Year").localizedstring()
            case "103": return LocalizedStringKey("Year").localizedstring()
            default: return LocalizedStringKey("Unknown").localizedstring()
        }
    }
    
    /* STRING */ private func ProductNames(id: String) -> String {
        switch id {
            case "102": return LocalizedStringKey("Monthly").localizedstring()
            case "7777": return LocalizedStringKey("Supporter").localizedstring()
            case "103": return LocalizedStringKey("Annually").localizedstring()
            default: return LocalizedStringKey("Unknown ID").localizedstring()
        }
    }
}


struct ListFeatureList: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @State var expand = false
    
    @State var badgeSizeTrail: CGSize = .zero
    
    @State var badgeSizeFree: CGSize = .zero
    
    @State var badgeSizePro: CGSize = .zero
    
    var body: some View {
        VStack {
            VStack(spacing: 10) {
                
                FeatureRowHeader()
                
                ForEach( features , id: \.id) { feature in
                    FeatureRow(feature: feature)
                }
                
                if expand {
                    ForEach( moreFeatures , id: \.id) { feature in
                        FeatureRow(feature: feature)
                    }
                }
                
            }
            .padding()
            
            Text("* 14-day free trial")
               .font(.footnote)
               .foregroundColor(currentTheme.text)
               .multilineTextAlignment(.leading)
               .padding()
            
            Text("A single premium membership is available on each platform (iOS, watchOS).\n\nFamily sharing allows you and up to five other family members to use Pro Prosthesis.")
               .font(.footnote)
               .foregroundColor(currentTheme.text)
               .padding()
            
            HStack {
                Spacer()
                Button(expand ? "Show less" : "View all") {
                    let animation: Animation = .easeOut
                    withAnimation(animation, {
                        expand.toggle()
                    })
                }
                Spacer()
            }
            .padding(10)
            .background(.ultraThinMaterial)
        }
        .foregroundColor(currentTheme.text)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .padding(.horizontal)
    }
    
    @ViewBuilder func FeatureRowHeader() -> some View {
        HStack {
            Spacer()
            
            TextBadge(text: "Trail").saveSize(in: $badgeSizeTrail)
            
            TextBadge(text: "Free").saveSize(in: $badgeSizeFree)
            
            TextBadge(text: "Pro").saveSize(in: $badgeSizePro)
            
        }
    }
    
    @ViewBuilder func FeatureRow(feature: ProFeature) -> some View {
        HStack {
            feature.featureIcon
            
            Text(feature.name)
                .font(.footnote)
            
            if feature.trail ?? true {
                Text("*")
                    .font(.footnote)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Image(systemName: feature.imageIconTrail)
                    .font(.caption.bold())
                    .circleBackground(foregroundColor: feature.iconColorTrail, backgroundColor: feature.iconColorTrail.opacity(0.4))
                    .foregroundColor(feature.iconColorPremium)
                Spacer()
            }
            .frame(width: badgeSizeTrail.width)
            
            HStack {
                Spacer()
                Image(systemName: feature.imageIconBasic)
                    .font(.caption.bold())
                    .circleBackground(foregroundColor: feature.iconColorBasic, backgroundColor: feature.iconColorBasic.opacity(0.4))
                    .foregroundColor(feature.iconColorPremium)
                Spacer()
            }
            .frame(width: badgeSizeFree.width)

            HStack {
                Spacer()
                Image(systemName: feature.imageIconPremium)
                    .font(.caption.bold())
                    .circleBackground(foregroundColor: feature.iconColorPremium, backgroundColor: feature.iconColorPremium.opacity(0.4))
                    .foregroundColor(feature.iconColorPremium)
                Spacer()
            }
            .frame(width: badgeSizePro.width)
           
            
        }
    }
    
    private let features: [ProFeature] = [
        ProFeature(icon: "icloud.fill", name: "100% ad-free", basic: false, trail: false ),
        ProFeature(icon: "icloud.fill", name: "Cross-device sync", basic: false, trail: false ),
        ProFeature(icon: "icloud.fill", name: "iCloud sync", basic: false, trail: false ),
        ProFeature(icon: "chart.line.uptrend.xyaxis", name: "Standard statistics", basic: true),
        ProFeature(icon: "chart.line.uptrend.xyaxis", name: "Advanced statistics", basic: false)
    ]
    
    private let moreFeatures: [ProFeature] = [
        ProFeature(icon: "square.dashed", name: "More widget", basic: false ),
        ProFeature(icon: "square.dashed", name: "Advanced Widget function", basic: false ),
        ProFeature(icon: "person.2.fill", name: "Unlimited contacts", basic: false, trail: false),
        ProFeature(name: "Insights and trends", basic: false)
    ]
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

