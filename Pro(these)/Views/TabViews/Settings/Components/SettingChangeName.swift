//
//  SettingChangeName.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 27.04.23.
//

import SwiftUI

struct SettingName: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var image: String
    
    var info: String
    
    var color: Color
    
    @Binding var username: String
    
    var body: some View {
        HStack(){
            VStack(){
                Image(systemName: image)
                    .frame(width: 20, height: 20)
                    .foregroundColor(currentTheme.text)
            }
            .padding(6)
            .background(color)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(currentTheme.text, lineWidth: 1)
            )
           
            VStack(alignment: .leading){
                TextField(username == "" ? "Name" : username, text: $username)
                   .foregroundColor(currentTheme.text)
                   .textFieldStyle(RoundedBorderTextFieldStyle())
                   .font(.body)
                   .fontWeight(.medium)
                   .foregroundColor(currentTheme.text)
                   .toggleStyle(SwitchToggleStyle(tint: .green))
                   .padding(.bottom, 5)
            }
            .padding(.leading)
            
        }
        .frame(maxWidth: .infinity ,alignment: .leading)
        .padding(.all, 12)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.5))
        .cornerRadius(10)
    }
}

struct SettingDate: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var image: String
    
    var info: LocalizedStringKey
    
    var color: Color
    
    @State var showDatePicker = true
    
    @Binding var date: Date
    
    var body: some View {
        HStack(){
            VStack(){
                Image(systemName: image)
                    .frame(width: 20, height: 20)
                    .foregroundColor(currentTheme.text)
            }
            .padding(6)
            .background(color)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(currentTheme.text, lineWidth: 1)
            )
           
            VStack(alignment: .leading){
                DatePicker(info, selection: $date, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(currentTheme.text)
                    .padding(.bottom, 5)
            }
            .padding(.leading)
            
        }
        .frame(maxWidth: .infinity ,alignment: .leading)
        .padding(.all, 12)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.5))
        .cornerRadius(10)
    }
}
