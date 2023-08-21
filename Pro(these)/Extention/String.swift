//
//  String.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 18.07.23.
//

import SwiftUI

extension String {    
    var isValidEmail: Bool {
        let emailValidationRegex = "^[\\p{L}0-9!#$%&'*+\\/=?^_`{|}~-][\\p{L}0-9.!#$%&'*+\\/=?^_`{|}~-]{0,63}@[\\p{L}0-9-]+(?:\\.[\\p{L}0-9-]{2,7})*$"  // 1

        let emailValidationPredicate = NSPredicate(format: "SELF MATCHES %@", emailValidationRegex)  // 2

        return emailValidationPredicate.evaluate(with: self)  // 3
    }
    
    var localized: LocalizedStringKey {
        return LocalizedStringKey(self)
    }
    
    func hasProduct(_ abo: AboType) -> Bool {
        if self != "" && abo == AboType.hasPro  {
            return true
        } else {
            
            if self == abo.getString {
                return true
            }  else {
                return false
            }
            
        }
    }
    
    var prosthesisKinds: LocalizedStringKey {
        switch self {
        case "Everyday" : return "Everyday Prosthesis"
        case "Waterproof" : return "Waterproof Prosthesis"
        case "Replacement" : return "Replacement Prosthesis"
        case "Sport" : return "Sports Prosthesis"
        case "Sports" : return "Sports Prosthesis"
        case "No Kind" : return "No Prosthesis"
        default:
            return "No Prosthesis"
        }
    }
    
    var linerFor: LocalizedStringKey {
        switch self {
        case "Everyday" : return "Everyday Prosthesis Liner"
        case "Waterproof" : return "Waterproof Prosthesis Liner"
        case "Replacement" : return "Replacement Prosthesis Liner"
        case "Sport" : return "Sports Prosthesis Liner"
        case "Sports" : return "Sports Prosthesis Liner"
        case "No Kind" : return "No Prosthesis Liner"
        default:
            return "No Prosthesis"
        }
    }
    
    var oneToOneOrderSubline: LocalizedStringKey {
        switch self {
        case "Everyday" : return "Order your liner for the Everyday Prosthesis in good time!"
        case "Waterproof" : return "Order your liner for the Waterproof Prosthesis in good time!"
        case "Replacement" : return "Order your liner for the Replacement Prosthesis in good time!"
        case "Sport" : return "Order your liner for the Sports Prosthesis in good time!"
        case "Sports" : return "Order your liner for the Sports Prosthesis in good time!"
        case "No Kind" : return "No Prosthesis Liner"
        default:
            return "No Prosthesis"
        }
    }
    
    var maintainceSubline: LocalizedStringKey {
        switch self {
        case "Everyday" : return "The next maintenance appointment for your Everyday Prosthesis!"
        case "Waterproof" : return "The next maintenance appointment for your Waterproof Prosthesis!"
        case "Replacement" : return "The next maintenance appointment for your Replacement Prosthesis!"
        case "Sport" : return "The next maintenance appointment for your Sports Prosthesis!"
        case "Sports" : return "The next maintenance appointment for your Sports Prosthesis!"
        case "No Kind" : return "No Prosthesis"
        default:
            return "No Prosthesis"
        }
    }
    
    var maintainceFor: LocalizedStringKey {
        switch self {
        case "Everyday" : return "Maintaince of the Everyday Prosthesis"
        case "Waterproof" : return "Maintaince of the Waterproof Prosthesis"
        case "Replacement" : return "Maintaince of the Replacement Prosthesis"
        case "Sport" : return "Maintaince of the Sports Prosthesis"
        case "Sports" : return "Maintaince of the Sports Prosthesis"
        case "No Kind" : return "No Prosthesis"
        default:
            return "No Prosthesis"
        }
    }
    
}

enum AboType: String, CaseIterable {
    case developer = "7777"
    case yearly = "103"
    case monthy = "102"
    case none = ""
    case hasPro = "pro"
    
    var getString: String {
        switch self {
        case .developer : return "7777"
        case .yearly : return "103"
        case .monthy : return "102"
        case .none: return ""
        case .hasPro : return "pro"
        }
    }
    
    var getType: AboType {
        switch self.rawValue {
            case "7777" : return .developer
            case "103"  : return .yearly
            case "102" : return .monthy
            case "" : return .none
            case "pro": return .hasPro
        default:
                return .none
        }
    }
}
