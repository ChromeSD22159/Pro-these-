//
//  LoginViewModel.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 22.05.23.
//

import Foundation
import SwiftUI
import Combine
import LocalAuthentication

class LoginViewModel: ObservableObject {
    
    @Published var authorizationError: Error?
    @Published var appUnlocked:Bool = false
    @Published var pin = false
    @Published var codeBlock = false
    init(){
        self.pin = getIsPinSet()
    }
    
    func getIsPinSet() -> Bool {
        return AppConfig.shared.userPin != "" ? true : false
    }
    
    func requestBiometricUnlock(type: LABiometryType) {
        let context = LAContext()
        
        var error: NSError? = nil
        
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if canEvaluate {
            if context.biometryType == .faceID {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "To access your data") { (success, error) in
                    
                    if success {
                        DispatchQueue.main.async {
                            self.appUnlocked = true
                            self.authorizationError = error
                        }
                    }
                    if (error != nil) {
                        print(error!)
                    }
                }
            }
            
            // FIXME: ADD TOUCHID
            if context.biometryType == .touchID {
                
            }
        } else {
            //print("not id")
        }
    }
    
    func faceIdIsAccepted() -> Bool {
        let context = LAContext()
      
        var error: NSError? = nil
      
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        return canEvaluate
    }
    
}
