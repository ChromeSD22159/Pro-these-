//
//  SettingManager.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 28.11.23.
//

import SwiftUI

struct SettingManager: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct SettingsAPIResponse: Codable {
    let data: SettingsData
    let meta: Meta
    
    enum CodingKeys: String, CodingKey {
        case data, meta
    }
}

struct SettingsData: Codable {
    let id: Int
    let attributes: SettingsAttributes
    
    enum CodingKeys: String, CodingKey {
        case id, attributes
    }
}

struct SettingsAttributes: Codable {
    let createdAt: String
    let updatedAt: String
    let locale: String
    let settings: [Setting]
    
    enum CodingKeys: String, CodingKey {
        case createdAt, updatedAt, locale, settings
    }
}

struct Setting: Codable {
    let id: Int
    let component: String
    let title: String
    let items: [SettingItem]
    
    enum CodingKeys: String, CodingKey {
        case id, __component, title, items
    }
    
    var __component: String {
        return component
    }
}

struct SettingItem: Codable {
    let id: Int
    let desc: String
    let title: String
    let state: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, desc, title, state
    }
}

struct Meta: Codable {
    // Hier Meta-Daten hinzufügen, wenn vorhanden
}
