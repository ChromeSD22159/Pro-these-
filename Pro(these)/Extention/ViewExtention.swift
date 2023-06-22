//
//  ViewExtention.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 25.04.23.
//

import SwiftUI
import UIKit

extension View {
    func fullSizeTop() -> some View {
        modifier(FullSizeTop())
    }
    
    func fullSizeCenter() -> some View {
        modifier(FullSizeCenter())
    }
    
    func haptic() -> some View {
        modifier(hapticModifier())
    }
    
    func blurredSheet<Content:View>(_ style: AnyShapeStyle, show: Binding<Bool>, onDismiss: @escaping ()->(), @ViewBuilder content: @escaping ()-> Content) -> some View { self
        .sheet(isPresented: show) {
            
        } content: {
            content()
                .background(RemoveBackgroundColor())
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(
                    Rectangle()
                        .fill(style)
                        .ignoresSafeArea(.container, edges: .all)
                )
        }
        /*
       .sheet(isPresented: show, onDismiss: onDismiss) {
           content()
               .background(RemoveBackgroundColor())
               .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
               .background(
                   Rectangle()
                       .fill(style)
                       .ignoresSafeArea(.container, edges: .all)
               )
       }
         */
    }
    
    func blurredOverlaySheet<Content:View>(_ style: AnyShapeStyle, show: Binding<Bool>, onDismiss: @escaping ()->(), @ViewBuilder content: @escaping ()-> Content) -> some View { self
       .fullScreenCover(isPresented: show, onDismiss: onDismiss) {
           content()
               .background(RemoveBackgroundColor())
               .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
               .background(
                   Rectangle()
                       .fill(style)
                       .ignoresSafeArea(.container, edges: .all)
               )
       }
    }
}

struct FullSizeTop: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct hapticModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                print("haptic")
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
            }
        
    }
}

struct FullSizeCenter: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

struct RemoveBackgroundColor: UIViewRepresentable {
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            uiView.superview?.superview?.backgroundColor = .clear
        }
    }
    
    func makeUIView(context: Context) -> UIView {
        return UIView()
    }
}
