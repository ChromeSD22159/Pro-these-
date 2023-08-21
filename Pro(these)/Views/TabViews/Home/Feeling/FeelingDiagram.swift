//
//  FeelingDiagram.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 26.07.23.
//

import SwiftUI
import Charts

struct FeelingDiagram: View {
    @FetchRequest var feelingRequest: FetchedResults<Feeling>
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var dates: [(id: UUID, date: Date)] {
        let dates = Date().extractLastDays(7)
        //dates.append((id: UUID(), date: Date().tomorrow))
        return dates.sorted(by: { $0.date > $1.date })
    }
    
    var feelings: [(id: UUID, value: Int, date: Date)] {
        
        let dict = Dictionary(grouping: self.feelingRequest, by: { (item) -> DateComponents in
            let date = Calendar.current.dateComponents([.year, .month, .day], from: (item.date!))
            return date
        }).map({ (date, value) in
            let newDate = Calendar.current.date(from: date)!
            let count = value.count
            let sum = value.map({
                return convertAxis(int: Int( ($0.name?.suffix(1))! ) ?? 0)
            }).reduce(0,+)
                
            return (id: UUID(), value: sum / count, date: newDate)
        })
        
        return dict.sorted(by: { $0.date > $1.date})
    }
    
    init() {
        let date = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -6, to: date)!.startEndOfDay().start
        let endDate = Date()
        _feelingRequest = FetchRequest<Feeling>(sortDescriptors: [], predicate: NSPredicate(format: "(date >= %@) AND (date <= %@)", startDate as CVarArg, endDate as CVarArg))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Mood Chart")
                    .font(.body.bold())
                    .foregroundColor(currentTheme.text)
                
                Text("Your mood history this week.")
                    .font(.caption2)
                    .foregroundColor(currentTheme.text)
            }
            
            ZStack {
                HStack(spacing: 10) {
                    
                    VStack(spacing: 6) {
                        ForEach(1..<6) { num in
                            
                            Image("feeling_\(num)")
                                .resizable()
                                .foregroundColor(currentTheme.hightlightColor.opacity(Double(convertAxis(int: num)) * 2 / 10))
                                .frame(width: 20, height: 20)
                        }
                    }
                    .padding(.bottom, 30)
                    .opacity(feelings.count == 0 ? 0.5 : 1)
                    .blur(radius: feelings.count == 0 ? 2 : 0)
                    
                    Spacer()

                    Chart() {
                        RuleMark( x: .value("Today", Date()) )
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                            .foregroundStyle(currentTheme.textGray.opacity(0.5))
                        
                        ForEach(dates, id: \.id) { week in
                            let res = feelings.filter({ feeling in
                                Calendar.current.isDate(feeling.date, inSameDayAs: week.date)
                            })
                            
                            AreaMark(
                                x: .value("Date", week.date),
                                y: .value("Feeling", res.first?.value ?? 0)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [
                                        currentTheme.hightlightColor.opacity(0.75),
                                        currentTheme.hightlightColor.opacity(0.1),
                                        currentTheme.hightlightColor.opacity(0)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom)
                            )
                            
                            LineMark(
                                x: .value("Date", week.date),
                                y: .value("Feeling", res.first?.value ?? 0 )
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(currentTheme.hightlightColor)
                            .lineStyle(.init(lineWidth: 3))
                            .symbol {
                                ZStack {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 12)
                                    
                                    Circle()
                                        .fill(currentTheme.hightlightColor)
                                        .frame(width: 6)
                                }
                            }
                        }
                    }
                    .chartYScale(range: .plotDimension(padding: 0))
                    .chartXScale(range: .plotDimension(padding: 0))
                    .chartYAxis {
                        
                        let values = Array(stride(from: 0, to: 6, by: 1.0))
                        
                        AxisMarks(position: .trailing, values: values) { axis in

                            AxisValueLabel() {
                                if let axis = axis.as(Double.self) {
                                    Text("\(String(format: "%.0f", axis))")
                                        .font(.system(size: 8))
                                        .opacity(0)
                                }
                            }
                        }
                    }
                    //.chartYAxis(.hidden)
                    .chartXAxis {
                        AxisMarks(position: .bottom, values: .stride(by: .day, count: 7)) { date in
                            AxisValueLabel() {
                                if let d = date.as(Date.self) {
                                    Text(d.dateFormatte(date: "EEE", time: "").date)
                                }
                            }
                        }
                    }
                    .chartXAxis(.hidden)
                    .opacity(feelings.count == 0 ? 0.1 : 1)
                    .blur(radius: feelings.count == 0 ? 2 : 0)
                }
                
                if feelings.count == 0 {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("You have not entered any moods yet")
                                .font(.footnote.bold())
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
        }
        .homeScrollCardStyle(currentTheme: currentTheme)
    }
    
    func convertAxis(int: Int) -> Int {
        switch int {
            case 5: return 1
            case 4: return 2
            case 3: return 3
            case 2: return 4
            case 1: return 5
        default:
            return 1
        }
    }
}

struct FeelingDiagram_Previews: PreviewProvider {
    static var previews: some View {
        FeelingDiagram()
    }
}
