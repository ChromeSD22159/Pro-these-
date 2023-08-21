//
//  DistanceStatistic.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 18.05.23.
//

import SwiftUI
import Foundation

struct DistanceStatistic: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    var distance: Double
    var avgDistance: Double
    var weekDistanceCount: [ChartData]
    var currentDay: Date
    var percentSteps: Double
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .center, spacing: 20) {
                HStack(spacing: 15) {
                    Image("figure.prothese")
                        .imageScale(.large)
                        .font(.system(size: 60, weight: .semibold))
                    
                    VStack(alignment: .leading, spacing: 3) {
                       
                        Text("\( String(format: "%.1f", distance / 1000 ) )km")
                            .font(.system(size: 40, weight: .semibold))
                        
                        Text(currentDay, style: .date)
                            .fontWeight(.semibold)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 15) {
                        ring(image: "figure.run")
                            .frame(width: 25)
                        
                        Text("⌀ \( String(format: "%.1f", avgDistance ) )km ")
                            .font(.caption)
                    }
                    
                    HStack(spacing: 15) {
                        ring(image: "figure.run")
                            .frame(width: 25)
                        
                        Text("Total \( String(format: "%.1f", weekDistanceCount.map { $0.value }.reduce(0, +) ) )km")
                            .font(.caption)
                    }
                    
                   /* let diff = distance - (avgDistance * 1000)
                    let diffString = diff.sign == .minus ?  String(format: "%.0f", diff)  + "m weniger " : "+" + String(format: "%.0f", diff) + "m mehr"

                    // PercentualChangeBadge(final: distance, initial: avgDistance * 1000, text: diffString, type: .ColoredTextSignSum) */
                }
                .frame(width: 150)
            }
            
            HStack(spacing: 5) {
                let diff = distance - (avgDistance * 1000)
                let diffString = diff.sign == .minus ?  String(format: "%.0f", diff)  + "m " : String(format: "%.0f", diff) + "m mehr"
                let dayString: String = Calendar.current.isDateInToday(currentDay) ? "heute" : "am" + formattedDateFromString(dateString: currentDay, format:" dd.MM")
                
                Text("Du bist \(dayString), __\(String(format: "%.1f", distance / 1000))__ km gelaufen. Das sind __\( diffString )__ als der Durchschnitt der Woche.")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .frame(maxWidth: .infinity)
        .cornerRadius(15)
        .padding()
    }
    
    func formattedDateFromString(dateString: Date,format: String) -> String {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = format

        return outputFormatter.string(from: dateString)
    }
    
    func ring(image: String) -> some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 2))
                .foregroundStyle(.tertiary)
                .overlay {
                    // Foreground ring
                    Circle()
                        .trim(from: 0, to: withAnimation(.easeInOut) { percentSteps / 100 })
                        .stroke(currentTheme.hightlightColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                }
                .rotationEffect(.degrees(-90))
            
            Image(systemName: image)
        }
    }
}
