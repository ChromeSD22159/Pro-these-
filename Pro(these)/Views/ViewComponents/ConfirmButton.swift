//
//  ConfirmButton.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 04.05.23.
//

import SwiftUI

/// Creates a button with true text or icon to trigger the Confirm Context menu
/// ```swift
///Confirm(message: "Lösche \(task.text ?? "")", buttonIcon: "trash", content: {
///  Button("Löschen") {
///    eventManager.deleteTask(task)
///  }
///})
/// ```
struct Confirm<Content: View>: View {
    @State private var showingConfirmation = false
    var message: LocalizedStringKey?
    var buttonText: LocalizedStringKey?
    var buttonIcon: String?
    @ViewBuilder var content: Content
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    var body: some View {
        ZStack{
            Button(action: {
                showingConfirmation.toggle()
            }, label: {
                if let buttonIcon = buttonIcon, !buttonIcon.isEmpty, let buttonText = buttonText, buttonText == "" {
                    Image(systemName: "\(buttonIcon)")
                }
                if let buttonText = buttonText, buttonText != "", let buttonIcon = buttonIcon, buttonIcon.isEmpty {
                    Text(buttonText)
                }
                if let buttonText = buttonText, buttonText != "", let buttonIcon = buttonIcon, !buttonIcon.isEmpty  {
                    Label(buttonText, systemImage: buttonIcon)
                }
               
            })
        }
        .confirmationDialog("Change background", isPresented: $showingConfirmation) {
            content
        } message: {
            Text(message ?? "")
        }
    }
}
extension Confirm<EmptyView> {
    init(
        @ViewBuilder content: @escaping () -> Content) {
            self.content = content()
    }
}
