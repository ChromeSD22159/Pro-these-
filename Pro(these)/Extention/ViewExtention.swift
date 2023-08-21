//
//  ViewExtention.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 25.04.23.
//

import SwiftUI
import UIKit

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
         overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
    
    func borderGradient(width: CGFloat, edges: [Edge], linearGradient: LinearGradient) -> some View {
         overlay(EdgeBorder(width: width, edges: edges).foregroundStyle(linearGradient))
    }
    
    @ViewBuilder
    func hidden(_ state: Bool) -> some View {
        switch state {
        case true: self.hidden()
        case false: self
        }
    }

    @ViewBuilder
    func freeTrailCard(currentTheme: Theme) -> some View {
        HStack(alignment: .center, spacing: 20) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
            
            VStack(spacing: 5) {
                HStack {
                    Text("Welcome to Pro Prosthesis!")
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                }
                
                
                HStack {
                    
                    
                    if AppTrailManager.isInTrail {
                        
                        Text("You are still \(AppTrailManager.freeTrailCountdown) days in the test phase. During this time you can test some pro features for free.")
                            .font(.footnote)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("You have now tested the app for more than 14 days free of charge. If you want to continue using the Pro features, you need a Pro subscription!")
                            .font(.footnote)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .foregroundColor(currentTheme == Theme.orange ? currentTheme.text : currentTheme.primary)
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(currentTheme.hightlightColor.gradient)
        .cornerRadius(10)
        .padding(.horizontal, 20)
    }
    
    func translateReasons(_ string: String?) -> String {
        if let p = string {
            if p  == "weather" {
                return Locale.current.language.languageCode!.identifier == "de" ? "Wetter" : "Weather"
            } else if p  == "warmth" {
                return Locale.current.language.languageCode!.identifier == "de" ? "Wärme" : "Warmth"
            } else if p  == "cold" {
                return Locale.current.language.languageCode!.identifier == "de" ? "Kälte" : "Cold"
            } else if p  == "No Painkiller" {
                return Locale.current.language.languageCode!.identifier == "de" ? "Kein Schmerzmittel" : "No Painkiller"
            } else if p == "Choose" {
                return Locale.current.language.languageCode!.identifier == "de" ? "Wählen" : "Choose"
            } else {
                return p
            }
        } else {
            return ""
        }
    }
    
    func fullSizeTop() -> some View {
        modifier(FullSizeTop())
    }
    
    func fullSizeCenter() -> some View {
        modifier(FullSizeCenter())
    }
    
    func haptic() -> some View {
        modifier(hapticModifier())
    }
    
    func flipHorizontal() -> some View {
        modifier(FlipHorizontal())
    }
    
    func viewSize(sizeBinding: Binding<CGSize>, printInConsole: Bool, viewName: String) -> some View {
        modifier(ViewSize(size: sizeBinding, printInConsole: printInConsole, viewName: viewName))
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
  
    func sayHallo(name: String) -> some View {
        let hour = Calendar.current.component(.hour, from: Date())
        
        var string: LocalizedStringKey = ""
        
        var nameString = ""
        if name != "" {
            nameString = ", \(name)"
        }

        switch hour {
            case 6..<12 : string = LocalizedStringKey("Good morning\(nameString)!")
            case 12 : string = LocalizedStringKey("Hello\(nameString)!")
            case 13..<17 :  string = LocalizedStringKey("Hello\(nameString)!")
            case 17..<22 : string = LocalizedStringKey("Good evening\(nameString)!")
            default: string = LocalizedStringKey("Hello\(nameString)!")
        }
        
        return Text(string)
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

struct ViewSize: ViewModifier {
    
    @Binding var size: CGSize
    
    var printInConsole: Bool
    
    var viewName: String
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear // we just want the reader to get triggered, so let's use an empty color
                        .onAppear {
                            if printInConsole {
                                print("\(viewName): \(proxy.size.width)")
                            }
                        }
                }
            )
    }
}

struct FullSizeCenter: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

struct FlipHorizontal: ViewModifier {
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
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


struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        edges.map { edge -> Path in
            switch edge {
            case .top: return Path(.init(x: rect.minX, y: rect.minY, width: rect.width, height: width))
            case .bottom: return Path(.init(x: rect.minX, y: rect.maxY - width, width: rect.width, height: width))
            case .leading: return Path(.init(x: rect.minX, y: rect.minY, width: width, height: rect.height))
            case .trailing: return Path(.init(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height))
            }
        }.reduce(into: Path()) { $0.addPath($1) }
    }
}


struct InfoButton: View {
    
    private var currentTheme: Theme {
        return ThemeManager().currentTheme()
    }
    
    var systemImage: String? = nil
    var infoText: String
    var color: Color? = nil
    
    @State var showState = false
    
    var body: some View {
        ZStack {
            Button(action: {
                withAnimation(.easeOut) {
                    showState.toggle()
                }
            }, label: {
                Image( systemName: systemImage ?? "info.circle")
                    .foregroundColor(color ?? currentTheme.hightlightColor)
                    .padding(5)
                    .multilineTextAlignment(.trailing)
            })
            .popover(isPresented: $showState) {
                ZStack {
                    currentTheme.gradientBackground(nil).ignoresSafeArea()
                                
                    VStack {
                        Text(infoText)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                    .padding()
                    .onTapGesture {
                        showState.toggle()
                    }
                    
                }
            }
        }
    }
}
