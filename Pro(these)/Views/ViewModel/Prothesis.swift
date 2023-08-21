//
//  prothesis.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 04.08.23.
//

import SwiftUI

enum prothesis: LocalizedStringKey, CaseIterable {
    
    case aboveKnee = "Above knee Prothesis"
    case belowKnee = "Below knee Prothesis"
    case none
    
    static var allTypes: [prothesis.type] {
       return [.aboveKnee, .belowKnee]
    }
    
    static var allKinds: [prothesis.kind] {
        return [.everyday, .waterproof, .replacement, .sport]
    }
    
    enum kind: LocalizedStringKey, CaseIterable {
        case everyday = "Everyday"
        case waterproof  = "Waterproof"
        case replacement  = "Replacement"
        case sport  = "Sports"
        case none = "No Kind"
        
        var rawValueWithBreak: String {
            switch self {
                case .everyday: return "Everyday\nProsthesis"
                case .waterproof: return "Waterproof\nProsthesis"
                case .replacement: return "Replacement\nProsthesis"
                case .sport: return "Sport\nProstheses"
                case .none: return "No Prostheses"
            }
        }
        
        var fullValue: LocalizedStringKey {
            switch self {
                case .everyday: return "Everyday Prosthesis"
                case .waterproof: return "Waterproof Prosthesis"
                case .replacement: return "Replacement Prosthesis"
                case .sport: return "Sport Prostheses"
                case .none: return "No Prostheses"
            }
        }
    }

    enum type: LocalizedStringKey, CaseIterable {
        case aboveKnee = "Above knee Prothesis"
        case belowKnee = "Below knee Prothesis"
        case none  = "No Type"
        
        var icon: String {
            switch self {
                case .aboveKnee: return "prothese.above"
                case .belowKnee: return "prothese.below"
                case .none: return "prothese.below"
            }
        }
    }
}

