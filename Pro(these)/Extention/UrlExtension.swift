//
//  UrlExtension.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 13.07.23.
//

import SwiftUI

extension URL {

    var isDeeplink: Bool {
        return scheme == "ProProthese" // match ProProthese://timer
    }
    
    var tabIdentifier: Tab? {
        guard isDeeplink else {
            return .home
        }
        
        switch host {
            case "showFeeling" : return .feeling
            case "addFeeling" : return .feeling
            case "addPain": return .pain
            case "stopWatchStart": return .stopWatch
            case "stopWatchStop": return .stopWatch
            case "statisticSteps": return .healthCenter
            case "statisticWorkout": return .healthCenter
            
            case "event" : return .event
            case "healthCenter" : return .healthCenter
            case "feeling" : return .healthCenter

            default: return nil
        }
    }
    
    var tabAction: String? {
        return host
    }
    
}
