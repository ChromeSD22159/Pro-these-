//
//  GoogleInterstitialAd.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 29.08.23.
//

import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

final class GoogleInterstitialAd: NSObject, GADFullScreenContentDelegate, ObservableObject {

    private var interstitial: GADInterstitialAd?
    
    override init() {
        super.init()
        requestInterstitialAds()
    }

    func requestInterstitialAds() {
        let request = GADRequest()
        let unitID = AppConfig.shared.googleInterstitialAds == .dev ? "ca-app-pub-3940256099942544/4411468910" : "ca-app-pub-5150691613384490/2062248759"
        request.scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            GADInterstitialAd.load(withAdUnitID: unitID, request: request, completionHandler: { [self] ad, error in
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

class AdsViewModel: ObservableObject {
    static let shared = AdsViewModel()
    
    @Published var nextAdsShowen: Date? = nil
    
    @Published var interstitial = GoogleInterstitialAd()
    @Published var showInterstitial = false {
        didSet {
            if !AppConfig.shared.hasPro {
                if showInterstitial && !AppConfig.shared.hasPro {
                    print("SHOW Interstitial Ads")
                    if nextAdsShowen != nil {
                        
                        if nextAdsShowen! < Date() {
                            interstitial.showAd()
                            showInterstitial = false
                            nextAdsShowen = Calendar.current.date(byAdding: .minute, value: 3, to: Date())
                        }
                        
                    } else {
                        interstitial.showAd()
                        showInterstitial = false
                        nextAdsShowen = Calendar.current.date(byAdding: .minute, value: 3, to: Date())
                    }
                    
                    
                } else {
                    interstitial.requestInterstitialAds()
                }
            }
            
        }
    }
}
