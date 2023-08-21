//
//  Tab.swift
//  Pro Prothese
//
//  Created by Frederik Kohler on 23.04.23.
//

import SwiftUI

enum Tab: String, Codable, CaseIterable, Identifiable {
    case home = "home"
    case healthCenter = "HealthCenter"
    case stopWatch = "StopWatch"
    case add = "AddFeeling"
    case event = "Eventplaner"
    case feeling = "Feeling"
    case pain = "PhantomPain"
    
    
    var id: Self { self }
    
    var allCases: [Tab] {
        return Tab.allCases
    }
    
    var randomTab: String {
        let index = allCases.count
        let randomIndex = Int.random(in: 0...(index - 1))
        return allCases[randomIndex].rawValue
    }
    
    func TabIcon() -> String {
        switch self {
            case .home: return "house.fill"
            case .healthCenter: return "chart.pie"
            case .stopWatch: return "stopwatch"
            case .add: return "plus"
            case .event: return "calendar.badge.clock"
            case .feeling: return "face.dashed"
            case .pain: return "bolt.fill"
        }
    }
    
    func TabTitle() -> String {
        switch self {
            case .home: return "Home"
            case .healthCenter: return "Statistic"
            case .stopWatch: return "Prothesis Recorder"
            case .add: return "plus"
            case .event: return "Calendar"
            case .feeling: return "Feeling"
            case .pain: return "Phantom limb pains"
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


