//
//  Tab.swift
//  Pro Prothese
//
//  Created by Frederik Kohler on 23.04.23.
//

import SwiftUI

enum Tab: String, Codable, CaseIterable, Identifiable {
    case healthCenter = "HealthCenter"
    case stopWatch = "StopWatch"
    case add = "AddFeeling"
    case event = "Eventplaner"
    //case feeling = "Feeling"
    case pain = "PhantomPain"
    
    
    var id: Self { self }
    
    func TabIcon() -> String {
        switch self {
            case .healthCenter: return "chart.pie"
            case .stopWatch: return "stopwatch"
            case .add: return "plus"
            case .event: return "calendar.badge.clock"
            //case .feeling: return "face.dashed"
            case .pain: return "bolt.fill"
        }
    }
    
    func TabTitle() -> String {
        switch self {
            case .healthCenter: return "Statitic"
            case .stopWatch: return "StopWatch"
            case .add: return "plus"
            case .event: return "Events"
            //case .feeling: return "Feeling"
            case .pain: return "PhantomPain"
        }
    }
}


enum SubTab: String, Codable, CaseIterable, Identifiable {
    case feeling = "Feeling"
    case stopWatch = "Workout"
    case pain = "Pain"
    case event = "Calendar"
    
    var id: Self { self }
    
    func TabIcon() -> String {
        switch self {
            case .feeling: return "face.dashed"
            case .stopWatch: return "stopwatch"
            case .pain: return "bolt.fill"
            case .event: return "calendar.badge.plus"
          
        }
    }
    
    func TabTitle() -> String {
        switch self {
            case .feeling: return "Feeling"
            case .stopWatch: return "StopWatch"
            case .pain: return "Pain"
            case .event: return "Calendar"
        }
    }
}


extension URL {

    var isDeeplink: Bool {
        return scheme == "ProProthese" // match ProProthese://timer
    }
    
    var tabIdentifier: Tab? {
        guard isDeeplink else {
            return nil
        }
        
        switch host {
        //case "step" : return .step
        case "event" : return .event
        case "healthCenter" : return .healthCenter
        case "feeling" : return .healthCenter
        case "stopWatch": return .stopWatch
        case "pain": return .pain
        default: return nil
        }
    }
    
    
}
