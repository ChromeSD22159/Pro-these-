//
//  ProProtheseWidgetBundle.swift
//  ProProtheseWidget
//
//  Created by Frederik Kohler on 13.06.23.
//

import WidgetKit
import SwiftUI

@main
struct ProProtheseWidgetBundle: WidgetBundle {
    
    var body: some Widget {
        //ProProtheseWidget()
        ProProtheseWidgetPain()
        ProProthesenWidgetStopWatch()
        ProProtheseWidgetFeeling()
        
        ProProtheseWidgetTodaySteps()
        ProProtheseWidgetTodayWorkouts()
        ProProtheseWidgetShowFeeling()
        
        ProProtheseWidgetLiveActivity()
    }
}
