//
//  SessionTabView.swift
//  ProWatchOS Watch App
//
//  Created by Frederik Kohler on 10.05.23.
//

import SwiftUI
import WatchKit

struct SessionTabView: View {
    
    //MARK: isLuminanceReduced
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @EnvironmentObject private var workoutManager: WorkoutManager
    @State private var selectedWorkout: SessionTab = .metrics
    
    var body: some View {
        VStack{
            Spacer()
            MetricsView()
            ControlView()
            Spacer()
        }
        .frame(maxHeight: .infinity)
        .navigationTitle(workoutManager.selectedWorkout?.name ?? "")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        //.navigationBarHidden(workoutManager.selectedWorkout == .nowPlaying)
        .onChange(of: workoutManager.running) { _ in
           let _ = TimerView()
        }
        .tabViewStyle(
            PageTabViewStyle(indexDisplayMode: isLuminanceReduced ? .never : .automatic)
        )
        .onChange(of: isLuminanceReduced) { _ in
            let _ = MetricsView()
        }
    }
}

struct SessionTabView_Previews: PreviewProvider {
    static var previews: some View {
        SessionTabView()
            .environment(\.locale, Locale(identifier: "de"))
    }
}

enum SessionTab: String, Codable, Identifiable {
    case controls
    case timer
    case metrics
    case nowPlaying
    
    var id: Self { self }
    
    func name() -> String {
        switch self {
        case .controls: return "Control"
        case .timer: return "Timer"
        case .metrics: return "Metrics"
        case .nowPlaying: return "nowPlaying"
        }
    }
}
