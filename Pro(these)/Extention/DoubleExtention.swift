//
//  DoubleExtention.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 14.07.23.
//

import SwiftUI

extension Double {
    var seperator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0;
        
        return formatter.string(from: NSNumber(value: self))!
    }
}
