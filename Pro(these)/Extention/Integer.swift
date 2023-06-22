//
//  Integer.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 22.06.23.
//

import SwiftUI

extension Int {
    func percent() {
        
    }
}

extension View {
    func PRINT(_ identier: String?, _ item: Any) {
        if AppConfig.shared.debug {
            print("\(identier ?? identier): \(item)")
        }
    }
}
