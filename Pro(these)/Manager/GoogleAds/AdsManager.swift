//
//  InterstitialSheet.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 24.07.23.
//

import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

/*
class AdsManager: NSObject, ObservableObject {
    
    final class Interstitial: NSObject, GADFullScreenContentDelegate, ObservableObject {

        private var interstitial: GADInterstitialAd?
        
        override init() {
            super.init()
            requestInterstitialAds()
        }

        func requestInterstitialAds() {
            let request = GADRequest()
            request.scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                GADInterstitialAd.load(withAdUnitID: AdsManager.GoogleAds.interstitial.blockID(type: AppConfig.shared.adsDebug ? .test : .product), request: request, completionHandler: { [self] ad, error in
                    if let error = error {
                        print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                        return
                    }
                    interstitial = ad
                    interstitial?.fullScreenContentDelegate = self
                })
            })
        }
        
        func showAd() {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene

            let root = windowScene?.windows.last?.rootViewController
            //let root = UIApplication.shared.windows.last?.rootViewController
            if let fullScreenAds = interstitial {
                fullScreenAds.present(fromRootViewController: root!)
            } else {
                print("ads not ready")
            }
        }
        
    }
    
    struct AdBannerView: UIViewRepresentable {

        let adUnitID: String

        let height: CGFloat?
        
        let width: CGFloat?
        
        func makeUIView(context: Context) -> GADBannerView {
            
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            
            let _ = (width != nil) ? width! : (windowScene?.screen.bounds.size.width)!
            
            let h = (height != nil) ? height! : 50
            
            let bannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: 400, height: h))) // Set your desired banner ad size
            bannerView.adUnitID = adUnitID
            bannerView.rootViewController = windowScene?.windows.first?.rootViewController
            bannerView.load(GADRequest())
            
            return bannerView
        }

        func updateUIView(_ uiView: GADBannerView, context: Context) {}
    }
    
    enum GoogleAds: String, CaseIterable {
        case banner, interstitial
        
        enum type: String{
            case test = "test"
            case product = "product"
        }
        
        func blockID(type: type) -> String {
            switch self {
            case .banner:
                // init https://docs.google.com/document/d/1o8RHKpoOPnZGEakvWap-6qxwGVQ4yhvd/mobilebasic
                switch type {
                    case .test: return "ca-app-pub-3940256099942544/6300978111"
                    case .product: return "ca-app-pub-5150691613384490/1993131842"
                }
            case .interstitial:
                switch type {
                    case .test: return "ca-app-pub-3940256099942544/4411468910"
                    case .product: return "ca-app-pub-5150691613384490/2062248759"
                }
            }
            
            
        }
    }
}
*/


