//
//  LoginScreen.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 22.05.23.
//

import SwiftUI
import LocalAuthentication

struct LoginScreen: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var vm: LoginViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    private var pinLimit: Int = 4
    
    @State var numbersFirst:[String] = []
    
    @State var numbersSecond:[String] = []
    
    var pinFirst: String {
        return numbersFirst.joined()
    }
    
    var pinSecond: String {
        return numbersSecond.joined()
    }
    
    @State var message: String = ""
    
    @State var titel = ""
   
    @State var attempts: Int = 0
    
    var body: some View {
        ZStack {
            currentTheme.radialBackground(unitPoint: nil, radius: nil).ignoresSafeArea()
            
            if vm.pin {
                EntryPin()
                .modifier(Shake(animatableData: CGFloat(attempts)))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                EntryPin()
                .modifier(Shake(animatableData: CGFloat(attempts)))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
    }
    
    @ViewBuilder
    func EntryPin() -> some View{
        VStack(alignment: .center){
            Spacer()
            
            if !vm.codeBlock {
                if vm.faceIdIsAccepted() && vm.pin {
                    VStack{
                        FaceIDLoginView(appUnlocked: $vm.appUnlocked)
                    }
                } else {
                    CodeEntry()
                }
                
                Text("Enter the code")
                .onTapGesture{
                    withAnimation{
                        vm.codeBlock.toggle()
                    }
                }
            } else {
                Label("FaceID", systemImage: "faceid" )
                .onTapGesture{
                    withAnimation{
                        vm.codeBlock.toggle()
                    }
                }
                CodeEntry()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    @ViewBuilder
    func CodeEntry() -> some View {
        if !vm.pin {
            Text("Create Pin Code")
        }
       
        VStack{
            Text("\( numbersFirst.joined().replacingOccurrences(of: " ", with: "*", options: .literal, range: nil) )")
            Text("\( numbersSecond.joined().replacingOccurrences(of: " ", with: "*", options: .literal, range: nil) )")
            Text(message)
        }
        VStack(spacing: 15){
            HStack(spacing: 15){
                numberBlock(1...3, size: 50)
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 15){
                numberBlock(4...6, size: 50)
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 15){
                numberBlock(7...9, size: 50)
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 15){
                ZStack {

                    Circle()
                        .strokeBorder(currentTheme.text, lineWidth: 2)
                        .frame(width: 50, height: 50)
                    
                    Text("Del")
                    
                }
                .onTapGesture(perform: {
                    AppConfig.shared.userPin = ""
                    vm.pin = false
                    numbersFirst = []
                    numbersSecond = []
                })
                
                numberBlock(0...0, size: 50)
                
                ZStack {

                    Circle()
                        .strokeBorder(currentTheme.text, lineWidth: 2)
                        .frame(width: 50, height: 50)
                    
                    Text("Reset")
                    
                }
                .onTapGesture(perform: {
                    resetPins(false)
                })
            }
            .frame(maxWidth: .infinity)
            
        }
    }
    
    @ViewBuilder
    func numberBlock(_ range: ClosedRange<Int>, size: CGFloat) -> some View {
        ForEach(range, id: \.self) { index in
            numberButton(int: index, size: size)
        }
    }
    
    @ViewBuilder
    func numberButton( int: Int, size: CGFloat ) -> some View {
        ZStack {

            Circle()
                .strokeBorder(currentTheme.text, lineWidth: 2)
                .frame(width: size, height: size)
            
            Text("\(int)")
                .font(.title)
            
        }
        .onTapGesture(perform: {
            message = ""
            // set pin
            if !vm.pin && numbersFirst.count < pinLimit {
                // set first Time the Pin
                numbersFirst.append(String(int))
            } else if !vm.pin && numbersSecond.count < pinLimit {
                // set second time the Pin
                numbersSecond.append(String(int))
            }
            
            if !vm.pin && numbersFirst.count == 4 && numbersSecond.count == 4 {
                numbersFirst == numbersSecond ? resetPins(true) : resetPins(false)
                
                numbersFirst = []
                numbersSecond = []
            }
            
            
            // enter pin for login
            if vm.pin && numbersFirst.count < pinLimit {
                
                if numbersFirst.count == 3 {
                    numbersFirst.append(String(int))
                    
                    if vm.pin && numbersFirst.count == 4 {
                       if pinFirst == AppConfig.shared.userPin {
                           withAnimation(.easeInOut){
                               vm.appUnlocked = true
                           }
                       } else {
                           withAnimation(.default) {
                               self.attempts += 1
                               self.resetPins(false)
                           }
                       }
                   }
                } else {
                    numbersFirst.append(String(int))
                }
            }
        })
    }
    
    func resetPins(_ bool:Bool){
        if bool {
            vm.pin = true
            AppConfig.shared.userPin = pinFirst
            
        } else {
            withAnimation(.default) {
                self.attempts += 1
            }
        }
        
        numbersFirst = []
        numbersSecond = []
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}

struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}


struct FaceIDLoginView: View {
    @Binding var appUnlocked: Bool
    @EnvironmentObject var vm: LoginViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    var body: some View {
        VStack(spacing: 24) {
           
            
            Button(action: {
                vm.requestBiometricUnlock(type: .faceID)
            }, label: {
                VStack(spacing: 20) {
                    Image(systemName: "faceid")
                        .resizable()
                        .frame(width: 50, height: 50)
                    
                    Text("Login with Face ID")
                        .fontWeight(.semibold)
                }
                .padding()
                .background(Material.ultraThinMaterial)
                .foregroundColor(currentTheme.text)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            })
        }
        .padding()
    }
}
