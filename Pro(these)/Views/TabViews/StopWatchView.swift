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
    
    var body: some View {
        GeometryReader { screen in
           
            ZStack{
                RadialGradient(gradient: Gradient(colors: [
                    Color(red: 5/255, green: 5/255, blue: 15/255).opacity(0.7),
                    Color(red: 5/255, green: 5/255, blue: 15/255).opacity(1)
                ]), center: .center, startRadius: 50, endRadius: 300)
                    .ignoresSafeArea()
                
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
    
    @EnvironmentObject var stateManager: StateManager
    
    @State var recorderState = false
    
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
                            .foregroundColor(.white)
                        
                    } else if stopWatchProvider.recorderState == .notStarted {
                        Text("")
                            .font(.system(size: 50))
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 15){
                    Button(action: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            tabViewManager.activeTab = .healthCenter
                        }
                    }, label: {
                        Image(systemName: "location.slash")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                            .frame(width: 50, height: 50)
                            .background(
                                Circle()
                                    .fill(Color.yellow)
                                    .frame(width: 50, height: 50)
                            )
                    })
                   
                    Text( stopWatchProvider.recorderState == .started ? "END" : "START" )
                        .font(Font.system(size: 20))
                        .italic()
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(width: 75, height: 75)
                        .background(
                           Circle()
                               .fill(Color.yellow)
                                .frame(width: 75, height: 75)
                        )
                        .onTapGesture {
                            switch stopWatchProvider.recorderState {
                                case .started :
                                    stopWatchProvider.stopRecording(completion: { bool in  })
                                stateManager.updateApplicationContext(with: ["state": false , "date": Calendar.current.date(byAdding: .year, value: -5, to: Date())!])
                                    recorderState = false
                                
                                case .notStarted:
                                    stopWatchProvider.startRecording(completion: { bool in  })
                                    stateManager.updateApplicationContext(with: ["state": true , "date":  Date()])
                                    recorderState = true
                                case .finished:
                                break
                            }
                        }
                        
                   
                   
                    //Image(systemName: stateManager.session.isWatchAppInstalled && stateManager.session.isReachable ? "applewatch" : "applewatch.slash")
                    Button(action: {
                        stateManager.paired = stateManager.session.isPaired
                    }, label: {
                        Image(systemName: stateManager.session.isReachable ? "applewatch" : "applewatch.slash")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                            .frame(width: 50, height: 50)
                            .background(
                                Circle()
                                    .fill(Color.yellow)
                                    .frame(width: 50, height: 50)
                            )
                    })
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
}

