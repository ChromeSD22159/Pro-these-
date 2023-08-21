//
//  CircleAnimationInBackground.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 25.04.23.
//

import SwiftUI

struct CircleAnimationInBackground: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @State private var animation:Bool = false
    @State private var blur:CGFloat = 0
    @State private var scale:CGFloat = 0
    @State private var x1:CGFloat = 0
    @State private var y1:CGFloat = 0
    @State private var x2:CGFloat = 0
    @State private var y2:CGFloat = 0
    
    var delay: Double
    var duration: Double
    
    var body: some View {
        
        VStack {
            GeometryReader { s in
                ZStack{
                    ZStack{
                        Circle()
                            .strokeBorder(currentTheme.text.opacity(0.08), lineWidth: 120)
                            .frame(width: 700)
                            .padding()
                            .blur(radius: blur)
                            .offset(x: x1, y: -y1)
                        
                        Circle()
                            .fill(currentTheme.text.opacity(0.08))
                            .frame(width: 400)
                            .padding()
                            .blur(radius: blur)
                            .offset(x: -50, y: 300)
                            .offset(x: x2, y: -y2)
                    }
                    .opacity(scale)
                    .scaleEffect(1)
                    .blur(radius: blur)
                        //.offset(x: x, y: -y)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        
        .onAppear(){
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                withAnimation(.easeInOut(duration: duration)){
                    
                   
                    if animation == false {
                        changeToTrueAnimation()
                    } else {
                        changeToFalseAnimation()
                    }
                                                                    
                }
            })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        
    }
    
    func changeToFalseAnimation(){
            animation.toggle()
            blur = 0
            scale = 1
            x1 = 0
            y1 = 100
            x2 = 0
            y2 = 000
    }
    
    func changeToTrueAnimation(){
            animation.toggle()
            blur = 6
            scale = 1
            x1 = 0
            y1 = 100
            x2 = 0
            y2 = 0
    }
}
