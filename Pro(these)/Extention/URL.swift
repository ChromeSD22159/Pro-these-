//
//  URL.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 14.06.23.
//

import Foundation
import SwiftUI

extension URL {
    func checkDeeplink() -> Bool {
        guard self.scheme == "ProProthese" else {
            print("Unknown URL, we can't handle this one!")
            return false
        }
        
        return true
    }
}

