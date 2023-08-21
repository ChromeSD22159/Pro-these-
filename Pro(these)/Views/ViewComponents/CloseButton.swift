//
//  CloseButton.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 21.06.23.
//

import SwiftUI

struct SheetHeader: View {
    
    var color: Color?
    
    private var title: LocalizedStringKey
    private var action: () -> Void
    
    init(title: LocalizedStringKey, action: @escaping () -> Void, text: String = "", color: Color = Color.white) {
        self.title = title
        self.action = action
        self.color = color
    }
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var body: some View {
        HStack(alignment: .center) {
            
            Text(title)
                .foregroundColor(color ?? currentTheme.textBlack)
                .padding(.leading)
            
            Spacer()
            
            HStack {
                Button(action: {
                    #if !targetEnvironment(simulator)
                    // Execute code only intended for the simulator or Previews
                    action()
                    #endif
                    
                    dismiss()
                }, label: {
                    HStack {
                        Spacer()
                        ZStack{
                            Image(systemName: "xmark")
                                .font(.title2)
                                .padding()
                                .foregroundColor(color ?? currentTheme.textBlack)
                        }
                    }
                })
            }

        }
    }
}

struct CloseButton: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var binding: Binding<Bool>
    
    var color: Color?
    
    var body: some View {
        HStack {
            Button(action: {
                #if !targetEnvironment(simulator)
                // Execute code only intended for the simulator or Previews
                binding.wrappedValue.toggle()
                #endif
            }, label: {
                HStack {
                    Spacer()
                    ZStack{
                        Image(systemName: "xmark")
                            .font(.title2)
                            .padding()
                            .foregroundColor(color ?? currentTheme.textBlack)
                    }
                }
                .padding()
            })
        }
    }
}

struct CloseButton_Previews: PreviewProvider {
    
    static var state = false
    
    static var previews: some View {
        Group {
            SheetHeader(title: "Titel", action: {
                print("")
            })
        }
        
        Group {
            SheetHeader(title: "Titel", action: {
                print("")
            })
        }
        
        Group {
            ZStack {
                Color.red.ignoresSafeArea()
                CloseButton(binding: .constant(state))
            }
        }
         //   SheetHeader(text: "Header", binding: .constant(state))
            
         //   CloseButton(binding: .constant(state))
    }
}
