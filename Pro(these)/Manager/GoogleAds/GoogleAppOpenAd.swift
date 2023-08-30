//
//  GoogleAppStart.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 29.08.23.
//

import SwiftUI
import GoogleMobileAds

final class GoogleAppOpenAd: NSObject, GADFullScreenContentDelegate {
   var appOpenAd: GADAppOpenAd?
   var loadTime = Date()
   
   func requestAppOpenAd() {
       let request = GADRequest()
       
       guard !AppConfig.shared.hasPro else {
           print("[OPEN AD] HAS PRO")
           return
       }
       
       guard AppConfig.shared.googleAppOpenAdLastShow < Calendar.current.date(byAdding: .hour, value: -1, to: Date())! else {
           print("[OPEN AD] Last seen bore 1 hour")
           return
       }
       
       GADAppOpenAd.load(withAdUnitID: AppConfig.shared.googleAppOpenAd == .dev ? "ca-app-pub-3940256099942544/5662855259" : "ca-app-pub-5150691613384490/5456422024",
                         request: request,
                         orientation: UIInterfaceOrientation.portrait,
                         completionHandler: { (appOpenAdIn, _) in
                                self.appOpenAd = appOpenAdIn
                                self.appOpenAd?.fullScreenContentDelegate = self
                                self.loadTime = Date()
                                print("[OPEN AD] Ad is loaded")
                                self.tryToPresentAd()
                         })
   }
   
   func tryToPresentAd() {
       
       guard GoogleAppStartrequest.requestHandler else {
           return
       }
       
       if let gOpenAd = self.appOpenAd {
           
           let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
           
           gOpenAd.present(fromRootViewController: (windowScene?.windows.last?.rootViewController)!)
       } else {
           self.requestAppOpenAd()
       }
   }
   
   func wasLoadTimeLessThanNHoursAgo(thresholdN: Int) -> Bool {
       let now = Date()
       let timeIntervalBetweenNowAndLoadTime = now.timeIntervalSince(self.loadTime)
       let secondsPerHour = 3600.0
       let intervalInHours = timeIntervalBetweenNowAndLoadTime / secondsPerHour
       return intervalInHours < Double(thresholdN)
   }
   
   func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
       print("[OPEN AD] Failed: \(error)")
       requestAppOpenAd()
   }
   
   func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
       requestAppOpenAd()
       print("[OPEN AD] Ad dismissed")
   }
}


enum GoogleAppStartrequest {
    static var requestHandler: Bool {
        
        guard AppConfig.shared.googleAppOpenAdLastShow < Calendar.current.date(byAdding: .hour, value: -1, to: Date())! else {
            print("[OPEN AD] Last seen bore 1 hour")
            return false
        }
        
        AppConfig.shared.googleAppOpenAdLastShow = Date()
        
        return true
    }
}

