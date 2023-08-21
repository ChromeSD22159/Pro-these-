//
//  LanguageController.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 19.07.23.
//
import Foundation

struct LocalizedMessage {
    let title: String
    let body: String
}

struct Language {
    let code: String
    let name: String
}

final class LanguageController {
    static let shared = LanguageController()
    
    enum Constansts {
        enum AppGroup {
            static let identifier = "group.FK.Pro-these-"
        }
        enum UserDefaults {
            static let selectedLanguageKey = "SelectedLanguageKey"
        }
        enum Push {
            static let localizedMessageKey = "localized-message"
            static let titleKey = "title"
            static let bodyKey = "body"
        }
    }
    
    let availableLanguages = [
        Language(code: "en", name: "English"),
        Language(code: "de", name: "Deutsch")
    ]
    
    var defaultLanguage: Language { availableLanguages.first! }
    
    private init() {}
    
    func getLanguage() -> Language {
        guard let appGroupDefaults = UserDefaults(suiteName: Constansts.AppGroup.identifier) else {
            fatalError("Can't find app group with identifier: \(Constansts.AppGroup.identifier)")
        }
        
        if
            let selectedLanguage = appGroupDefaults.string(forKey: Constansts.UserDefaults.selectedLanguageKey),
            let language = availableLanguages.first(where: { $0.code == selectedLanguage })
        {
            return language
        }
        
        return defaultLanguage
    }
    
    func setLanguage(_ code: String) {
        guard let appGroupDefaults = UserDefaults(suiteName: Constansts.AppGroup.identifier) else {
            fatalError("Can't find app group with identifier: \(Constansts.AppGroup.identifier)")
        }
        
        appGroupDefaults.setValue(code, forKey: Constansts.UserDefaults.selectedLanguageKey)
    }
    
}

extension LanguageController {
    func getLanguage(at index: Int) -> Language? {
        guard index < availableLanguages.count else {
            return nil
        }
        
        return availableLanguages[index]
    }
    
    func index(for language: Language) -> Int? {
        if let index = availableLanguages.firstIndex(where: { $0.code == language.code }) {
            return index
        }
        
        return nil
    }
    
}

extension LanguageController {
    func extractLocalizedMessage(from userInfo: [AnyHashable: Any], for code: String) -> [String: String]? {
        guard
            let messages = userInfo[Constansts.Push.localizedMessageKey] as? [String: Any],
            let messageObject = messages[code] as? [String: String]
        else {
            return nil
        }
        
        return messageObject
    }
}
