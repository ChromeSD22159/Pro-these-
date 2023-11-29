//
//  ChartDataPacked.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 13.10.23.
//

import SwiftUI

struct ChartDataPacked: Identifiable {
    var id = UUID()
    var avg: Int
    var avgName: String
    var weekNr: Int
    var data: [ChartData]
}
