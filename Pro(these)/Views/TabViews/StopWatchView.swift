//
//  WorkOutEntryView.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 19.05.23.
//

import SwiftUI

struct StopWatchView: View {
    @StateObject var stopWatchProvider = StopWatchProvider()
    @StateObject var tabManager = TabManager()
    @StateObject var workoutStatisticViewModel = WorkoutStatisticViewModel()
    
    @EnvironmentObject var themeManager: ThemeManager

    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }

    var body: some View {
        GeometryReader { screen in
           
            ZStack{
                currentTheme.radialBackground(unitPoint: nil, radius: nil).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    HeaderComponent()
                        .padding(.top, 20)
                    
                    StopWatchRecordView().padding(.horizontal).environmentObject(stopWatchProvider)
                    
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
        }
    }
}

struct StopWatchRecordView: View {
    @EnvironmentObject var stopWatchProvider: StopWatchProvider
    @EnvironmentObject var tabViewManager: TabManager
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var ads: AdsViewModel
    @EnvironmentObject var stateManager: StateManager
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @State var recorderState = false
    
    @FetchRequest var allProthesis: FetchedResults<Prothese>
    
    init() {
        _allProthesis = FetchRequest<Prothese>(
            sortDescriptors: []
        )
    }
    
    var body: some View {
        ZStack {

            VStack {
                
                Spacer()
                
                HStack{
                    Spacer()
                    // Timer Started from the watch
                    if stopWatchProvider.recorderState == .started {
                        Text(stopWatchProvider.recorderStartTime!, style: .timer)
                            .font(.system(size: 50))
                            .italic()
                            .fontWeight(.bold)
                            .fontWeight(.medium)
                            .foregroundColor(currentTheme.text)
                        
                    } else if stopWatchProvider.recorderState == .notStarted {
                        Text("")
                            .font(.system(size: 50))
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 15){
                    
                    LiveActivitySwitch()
                   
                    Text( stopWatchProvider.recorderState == .started ? "END" : "START" )
                        .font(Font.system(size: 20))
                        .italic()
                        .fontWeight(.bold)
                        .foregroundColor(currentTheme.textBlack)
                        .frame(width: 75, height: 75)
                        .background(
                           Circle()
                               .fill(currentTheme.hightlightColor)
                                .frame(width: 75, height: 75)
                        )
                        .onTapGesture {
                            switch stopWatchProvider.recorderState {
                                case .started :
                                    stopWatchProvider.stopRecording(completion: { bool in
                                        stopWatchProvider.sharedState(false)
                                    })
                                    stateManager.updateApplicationContext(with: ["state": false , "date": Calendar.current.date(byAdding: .year, value: -5, to: Date())!])
                                    recorderState = false
                                
                                    // Show InterstitialSheet if not Pro
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                        if !appConfig.hasPro {
                                           ads.showInterstitial.toggle()
                                        }
                                    })
                                
                                
                                case .notStarted:
                                    stopWatchProvider.startRecording(completion: { bool in
                                        stopWatchProvider.sharedState(true)
                                    })
                                    stateManager.updateApplicationContext(with: ["state": true , "date":  Date()])
                                    recorderState = true
                                case .finished:
                                break
                            }
                        }
                        
                   
                   
                    /*Image(systemName: stateManager.session.isWatchAppInstalled && stateManager.session.isReachable ? "applewatch" : "applewatch.slash")
                    Button(action: {
                        stateManager.paired = stateManager.session.isPaired
                    }, label: {
                        Image(systemName: stateManager.session.isReachable ? "applewatch" : "applewatch.slash")
                            .font(.system(size: 20))
                            .foregroundColor(currentTheme.textBlack)
                            .frame(width: 50, height: 50)
                            .background(
                                Circle()
                                    .fill(currentTheme.hightlightColor)
                                    .frame(width: 50, height: 50)
                            )
                    })*/
                    
                    ProthesesSwitch()
               }
                .padding(.bottom, 30)
            }
            .onAppear{
                if stopWatchProvider.recorderFetchStartTime() != nil {
                    stopWatchProvider.recorderState = .started
                    stopWatchProvider.recorderStartTime = stopWatchProvider.recorderFetchStartTime()
                }
                
                stateManager.paired = stateManager.session.isPaired
            }
            .onChange(of: stateManager.paired, perform: { state in
                if state == true {
                    print("watch is avaible")
                }
            })
            .onChange(of: stateManager.state, perform: { state in
                if state == false {
                    self.recorderState = false
                }
            })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    func LiveActivitySwitch() -> some View {
        Menu(content: {
            Button(action: {
                appConfig.showLiveActivity = true
            }, label: {
                HStack {
                    Text("Show")
                    Spacer()
                    Image(systemName: "location")
                }
            })
            
            Button(action: {
                appConfig.showLiveActivity = false
            }, label: {
                HStack {
                    Text("Don't Show")
                    Spacer()
                    Image(systemName: "location.slash")
                }
            })
            
            Text("View your prosthesis timer on your lock screen and Dynamic Island.")
                .foregroundColor(currentTheme.textGray)
                .font(.system(size: 8))
        }, label: {
            Image(systemName: appConfig.showLiveActivity ? "location" : "location.slash")
                .font(.system(size: 25))
                .foregroundColor(currentTheme.textBlack)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(currentTheme.hightlightColor)
                        .frame(width: 50, height: 50)
                )
        })
    }
    
    @ViewBuilder
    func ProthesesSwitch() -> some View {
        Menu(content: {
            ForEach(self.allProthesis.reversed()) { prothese in
                Button(action: {
                    appConfig.selectedProthese = prothese.prosthesisKind.localizedstring()
                }, label: {
                    Image(prothese.prosthesisIcon)
                    Text(prothese.prosthesisKind)
                })
            }
            
            Text("Select a prostheses for which you want to start the timer.")
                .foregroundColor(currentTheme.textGray)
                .font(.system(size: 8))
        }, label: {
            if appConfig.selectedProthese == "" {
                Image(systemName: "rectangle.portrait.slash")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(currentTheme.textBlack)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(currentTheme.hightlightColor)
                            .frame(width: 50, height: 50)
                    )
            } else {
                
                ZStack {
                    Text(appConfig.selectedProthese.prefix(1) + "P")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(currentTheme.text)
                        .offset(y: -40)
                    
                    Image(allProthesis.first?.prosthesisIcon ?? "prothese.above")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundStyle(currentTheme.textBlack, currentTheme.textGray)
                        .flipHorizontal()
                }
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(currentTheme.hightlightColor)
                        .frame(width: 50, height: 50)
                )
                
            }
            
        })
        .onAppear{
            guard appConfig.selectedProthese == "" else {
                print("selectedProthese already set")
                return
            }
            
            guard allProthesis.first?.prosthesisKind.localizedstring() != nil else {
                print("allProthesis first hast no kind")
                return
            }
            
            guard allProthesis.count != 0 else {
                print("allProthesis is empty")
                appConfig.selectedProthese = ""
                return
            }
            
            appConfig.selectedProthese = (allProthesis.first?.prosthesisKind.localizedstring())!
            
            
        }
    }
}

