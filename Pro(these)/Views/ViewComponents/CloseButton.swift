//
//  CloseButton.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 21.06.23.
//

import SwiftUI

struct SheetHeader: View {
    
    var color: Color?
    
    private var title: String
    private var action: () -> Void
    
    init<S>(_ title: S, action: @escaping () -> Void, text: String = "", color: Color = Color.white) where S : StringProtocol {
        self.title = title as! String
        self.action = action
        self.color = color
    }
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        HStack(alignment: .center) {
            
            Text(title)
                .padding(.leading)
                .foregroundColor(color ?? .white)
            
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
                                .foregroundColor(color ?? .white)
                        }
                    }
                    .padding()
                })
            }

        }
        .padding()
    }
}

struct CloseButton: View {
    
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
                            .foregroundColor(color ?? .white)
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
            SheetHeader("Titel", action: {
                print("")
            })
        }
        
        Group {
            SheetHeader("Titel", action: {
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
