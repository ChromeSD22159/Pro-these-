//
//  SuggestionSheet.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 18.07.23.
//

import SwiftUI
import Messages
import MessageUI

struct SuggestionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @State private var email: String = ""
    @State var massage = ""
    @State var massagePlaceholder = "Was können wir tun, um die App zuverbessern?"
    @State private var emailValidation: Bool = false
    @State var error: [String] = []
    
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false
    
    var body: some View {
        VStack(spacing: 20) {
            header(header: "Verbesserungsvorschlag")
            
            formular()
                .padding(.horizontal)
            Spacer()
        }
    }
        
    @ViewBuilder
    func header(header: String) -> some View {
        HStack(spacing: 20) {
            
            Spacer()
            Spacer()
            
            Text(header)
                .font(.body.bold())

            Spacer()
            
            if emailValidation && !massage.isEmpty {
                Button(action: {
                    EmailController.shared.sendEmail(
                        subject: "Verbesserungsvorschlag \"Pro Prothese\"",
                        body: massage,
                        to: "frederik.kohler@prothese.pro")
                }, label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(currentTheme.text)
                        .padding()
                })
            } else {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "xmark")
                        .foregroundColor(currentTheme.text)
                        .padding()
                })
            }
           
        }
        .padding()
    }
    
    @ViewBuilder
    func formular() -> some View {
        VStack(spacing: 20) {
           
            
            ZStack {
                TextField("E-Mail:", text: $email)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(currentTheme.textGray, lineWidth: 1)
                   )
                    .onChange(of: email) { value in
                        withAnimation(.easeInOut) {
                            if value.isValidEmail {
                                emailValidation = true
                            } else {
                                emailValidation = false
                                error.append("wrong email formate")
                            }
                        }
                        
                    }
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                
                HStack {
                    Spacer()
                    
                    Image(systemName: emailValidation ? "checkmark.seal.fill" : "xmark.seal.fill")
                        .opacity(emailValidation ? 1 : 0)
                }
                .padding(.horizontal)
            }
            
            ZStack {
                if self.massage.isEmpty {
                        TextEditor(text: $massagePlaceholder)
                            .padding()
                            .scrollContentBackground(.hidden) //
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(currentTheme.textGray, lineWidth: 1)
                            )
                            .foregroundColor(currentTheme.textGray)
                            .disabled(true)
                } else {
                    
                }
                
                TextEditor(text: $massage)
                    .padding()
                    .scrollContentBackground(.hidden) //
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(currentTheme.textGray, lineWidth: 1)
                    )
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .opacity(self.massage.isEmpty ? 0.25 : 1)
            }
        }
    }
}

struct SuggestionSheet_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            
        }
        .preferredColorScheme(.dark)
        .blurredSheet(.init(.ultraThinMaterial), show: .constant(true), onDismiss: {}) {
            SuggestionSheet()
                .preferredColorScheme(.dark)
        }
       
    }
}

