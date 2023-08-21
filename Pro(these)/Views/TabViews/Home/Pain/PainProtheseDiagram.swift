//
//  FeelingProthesenDiagram.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 08.08.23.
//

import SwiftUI
import Charts

struct PainProtheseDiagram: View {
    @FetchRequest var painRequest: FetchedResults<Pain>
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    var dates: [(id: UUID, date: Date)] {
        let dates = Date().extractLastDays(7)
        return dates.sorted(by: { $0.date > $1.date })
    }
    
    var pains: [(prothese: String, data: [(id: UUID, value: Int, date: Date)])] {
        
        let dic = Dictionary(grouping: self.painRequest, by: { (item) -> String in
            if let prothese = item.prothese {
                return prothese.prosthesisKind.localizedstring()
            } else {
                return "nil"
            }
        }).mapValues({ (feelings) in
            
            Dictionary(grouping: feelings, by: { (item) -> DateComponents in
                let date = Calendar.current.dateComponents([.year, .month, .day], from: (item.date!))
                return date
            }).map({ (date, value) in
                let newDate = Calendar.current.date(from: date)!
                let count = value.count
                let sum = value.map({
                    return Int($0.painIndex)
                }).reduce(0,+)
                
                return (id: UUID(), value: sum / count, date: newDate)
            }).sorted(by: { $0.date > $1.date})
            
        })
        
        let x = dic.map({
            return (prothese: $0.key as String, data: $0.value)
        })//.sorted(by: { $0.prothese > $1.prothese })
        
        return x.filter({ $0.prothese != "nil" }).sorted(by: { $0.prothese > $1.prothese })
    }
    
    init() {
        let date = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -6, to: date)!.startEndOfDay().start
        let endDate = Date()
        _painRequest = FetchRequest<Pain>(sortDescriptors: [], predicate: NSPredicate(format: "(date >= %@) AND (date <= %@)", startDate as CVarArg, endDate as CVarArg))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Prostheses Pain Chart")
                    .font(.body.bold())
                    .foregroundColor(currentTheme.text)
                
                Text("Your pain progression in the prosthesis comparison.")
                    .font(.caption2)
                    .foregroundColor(currentTheme.text)
            }

            ZStack {
                zIndexChart(blur: pains.count == 0 ? 2 : 0)
                
                if pains.count == 0 {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("You have not yet added any pains to your prostheses")
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
    
    func vStackChart() -> some View {
        VStack(spacing: 25) {
            ForEach(pains, id: \.prothese) { prothese in
                
                VStack(spacing: 10) {
                    Text(prothese.prothese)
                        .font(.headline.bold())
                    
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
                        
                        
                        
                        Spacer()
                        
                        Chart() {
                            
                            RuleMark( x: .value("Today", Date()) )
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                                .foregroundStyle(currentTheme.textGray.opacity(0.5))
                            
                            
                            ForEach(dates, id: \.id) { week in
                                let res = prothese.data.filter({ feeling in
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
                    }
                }
                
            }
        }
    }
    
    func zIndexChart(blur: CGFloat) -> some View {
        HStack(spacing: 10) {
            
            VStack(spacing: 6) {
                ForEach(1..<11) { num in
                   
                    if num % 2 != 0 {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .resizable()
                                .foregroundColor(currentTheme.hightlightColor.opacity(Double(convertAxis(int: num)) * 2 / 10))
                                .frame(width: 20, height: 20)
                            
                            Text("\(convertAxis(int: num))")
                        }
                    }
                }
                
                HStack {
                    Image(systemName: "bolt.fill")
                        .resizable()
                        .foregroundColor(currentTheme.hightlightColor.opacity(Double(convertAxis(int: 10)) * 2 / 10))
                        .frame(width: 20, height: 20)
                    
                    Text("0")
                }
            }
            .padding(.bottom, 20)
            .opacity(pains.count == 0 ? 0.5 : 1)
            .blur(radius: blur)
            
            Spacer()
            
            Chart() {
                RuleMark( x: .value("Today", Date()) )
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundStyle(currentTheme.textGray.opacity(0.5))
                
                ForEach(pains, id: \.prothese) { prothese in
                    
                    ForEach(dates, id: \.id) { week in
                        let res = prothese.data.filter({ feeling in
                            Calendar.current.isDate(feeling.date, inSameDayAs: week.date)
                        })
                        
                        LineMark(
                            x: .value("Date", week.date),
                            y: .value("Feeling", res.first?.value ?? 0 )
                        )
                        .interpolationMethod(.catmullRom)
                        .lineStyle(.init(lineWidth: 3))
                    }
                    .foregroundStyle(by: .value("Prothese", prothese.prothese))
                }
            }
            .chartYScale(range: .plotDimension(padding: 10))
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
            .opacity(pains.count == 0 ? 0 : 1)
            .blur(radius: blur)
        }
    }
    
    func convertAxis(int: Int) -> Int {
        switch int {
            case 10: return 1
            case 9: return 2
            case 8: return 3
            case 7: return 4
            case 6: return 5
            case 5: return 6
            case 4: return 7
            case 3: return 8
            case 2: return 9
            case 1: return 10
            case 0: return 0
        default:
            return 0
        }
    }
}
