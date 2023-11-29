//
//  Gangbild.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 15.09.23.
//

import SwiftUI
import Charts

struct StepsTodayDiagram: View {
    @Environment(\.scenePhase) var scenePhase
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @StateObject var healthStore = HealthStoreProvider()
    
    private var currentTheme: Theme {
        return  ThemeManager().currentTheme()
    }
    
    var hightlightColor: Color
    
    @State var positionForNewColor: CGFloat = 0.0
    
    @State var stepData: [ChartData] = []
    
    @State var stepDataYesterday: [ChartData] = []
    
    @State var isTimerRunning = false
    
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    private var percent: CGFloat {
        return CGFloat(calculatePercentage(value: 25, percentageVal: Double(countedData - 1)) / 100)
    }
    
    private var countedData: Int {
        return stepData.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            HStack{
                VStack(alignment: .leading, spacing: 6) {
                    Text("Today Steps Statistic")
                        .font(.body.bold())
                        .foregroundColor(currentTheme.text)
                    
                    Text("Step history for today.")
                        .font(.caption2)
                        .foregroundColor(currentTheme.text)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack{
                        Text("- -")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(hightlightColor)
                        
                        Text("asd")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(hightlightColor)
                    }
                    
                    HStack{
                        Text("- -")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(currentTheme.textGray)
                        
                        Text("sd")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(currentTheme.textGray)
                    }
                }
            }
            
            HStack(spacing: 10) {
                
                ZStack {
                    
                    Chart() { // YESTERDAY
                        ForEach(stepDataYesterday.sorted(by: { $0.date > $1.date }), id: \.self) { hour in
                            
                            LineMark(
                                x: .value("Hour", hour.date),
                                y: .value("Steps", hour.value)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(currentTheme.textGray.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5,5]))
                        }
                    }
                    .chartYScale(range: .plotDimension(padding: 10))
                    .chartYAxis {
                        let values = Array(stride(from: 0, to: 100, by: 20))
                        
                        AxisMarks(position: .leading, values: values) { axis in

                            AxisValueLabel() {
                                if let axis = axis.as(Double.self) {
                                    Text("\( Int(axis) )")
                                        .font(.system(size: 8))
                                        .opacity(0)
                                }
                            }
                        }
                    }
                    .chartXScale(range: .plotDimension(padding: 20))
                    .chartXAxis {
                        AxisMarks(preset: .aligned, position: .bottom, values: .stride(by: .hour, count: 25)) { date in
                            AxisValueLabel() {
                                if let d = date.as(Date.self) {
                                    Text(d.dateFormatte(date: "", time: "H").time)
                                        .font(.system(size: 6))
                                        .opacity(0)
                                }
                            }
                        }
                    }
                    
                    Chart() { // TODAY
                        ForEach(stepData.sorted(by: { $0.date > $1.date }), id: \.self) { hour in
                            
                            AreaMark(
                                x: .value("Hour", hour.date),
                                y: .value("Steps", hour.value)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [
                                        currentTheme.hightlightColor.opacity(0.5),
                                        currentTheme.hightlightColor.opacity(0.1),
                                        currentTheme.hightlightColor.opacity(0)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom)
                            )
                            
                            LineMark(
                                x: .value("Hour", hour.date),
                                y: .value("Steps", hour.value)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(
                                .linearGradient(
                                    Gradient(
                                        stops: [
                                            .init(color: currentTheme.hightlightColor, location: 0),
                                            .init(color: currentTheme.hightlightColor, location: positionForNewColor),
                                            .init(color: .gray.opacity(0.0), location: positionForNewColor + 0.001),
                                            .init(color: .gray.opacity(0.0), location: 1),
                                        ]),
                                    startPoint: .leading,
                                    endPoint: .trailing)
                            )
                            .lineStyle(.init(lineWidth: 3))
                            .symbol {

                                if Calendar.current.isDateInThisHour(hour.date) {
                                    AnimatedCircle(size: 12, color: currentTheme.hightlightColor)
                                }
                                
                            }
                        }
                    }
                    .chartYScale(range: .plotDimension(padding: 10))
                    .chartYAxis {
                        
                        let maxT = stepData.map({ $0.value }).max() ?? 0
                        let maxY = stepDataYesterday.map({ $0.value }).max() ?? 0
                        let max = [maxT, maxY].max() ?? 0
                        
                        let yValues = stride(from: 0, to: (max + 1000).rounded(to: 1000, roundingRule: .up) , by: 1000).map { $0 }
                        
                        AxisMarks(position: .leading, values: yValues) { axis in

                            AxisValueLabel() {
                                if let axis = axis.as(Double.self) {
                                    Text("\( Int(axis) )")
                                        .font(.system(size: 8))
                                }
                            }
                        }
                    }
                    .chartXScale(range: .plotDimension(padding: 20))
                    .chartXAxis {
                        
                        let xValues = stepData.map { $0.date }
                        
                        AxisMarks(preset: .aligned, position: .bottom, values: xValues) { date in
                            AxisValueLabel() {
                                if let d = date.as(Date.self) {
                                    Text(d.dateFormatte(date: "", time: "HH").time)
                                        .font(.system(size: 6))
                                }
                            }
                        }
                    }
                    
                }
            }
        }
        .homeScrollCardStyle(currentTheme: currentTheme)
        .onAppear{
            resetData()
            extractDayInHours()
        }
        .onDisappear {
            resetData()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                resetData()
                extractDayInHours()
            }
        }
        .onReceive(timer) { _ in
            if self.isTimerRunning {
                
                guard positionForNewColor <= CGFloat(percent) else {
                    self.isTimerRunning.toggle()
                    return
                }
                
                positionForNewColor += 0.01
            }
        }
    }
    
    
    private func extractDayInHours() {
        let date = Date().startEndOfDay().start
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!.startEndOfDay().start
        
        for i in 0...24 {
            let hour = Calendar.current.date(byAdding: .hour, value: i, to: date)!
            
            let dateInterval = DateInterval(start: date, end: hour)
            
            HealthStoreProvider().readIntervalQuantityType(dateInterval: dateInterval, type: .stepCount, completion: { data in
                DispatchQueue.main.async {
                    stepData.append(ChartData(date: hour, value: data))
                }
            })
            
            let hourYesterday = Calendar.current.date(byAdding: .hour, value: i, to: yesterday)!
            
            let dateIntervalYesterday = DateInterval(start: yesterday, end: hourYesterday)
            
            HealthStoreProvider().readIntervalQuantityType(dateInterval: dateIntervalYesterday, type: .stepCount, completion: { data in
                DispatchQueue.main.async {
                    stepDataYesterday.append(ChartData(date: hour, value: data))
                }
            })
        }
    }
    
    private func resetData() {
        stepData = []
        stepDataYesterday = []
    }
    
    public func calculatePercentage(value:Double,percentageVal:Double)->Double{
        return 100.0 / value * percentageVal
    }
}
