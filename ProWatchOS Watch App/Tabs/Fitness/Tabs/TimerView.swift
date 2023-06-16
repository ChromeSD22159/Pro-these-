//
//  TimerView.swift
//  ProWatchOS Watch App
//
//  Created by Frederik Kohler on 10.05.23.
//

import SwiftUI

struct TimerView: View {
    
    private let formatStyle = Measurement<UnitLength>.FormatStyle(
        width: .abbreviated,
        numberFormatStyle: .number
    )
    
    var elapsedTime: TimeInterval = 0
    var showSubseconds = true
    @State private var timeFormatter = TimeFormatter()
    
    var body: some View {
        VStack(alignment: .center) {
            // MARK: - Timer
            HStack{
                Text( NSNumber(value: elapsedTime), formatter: timeFormatter )
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.yellow)
                
            }
            .onChange(of: showSubseconds) {
                timeFormatter.showSubseconds = $0
            }
        }
        .padding()
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
            .environment(\.locale, Locale(identifier: "de"))
    }
}

// MARK: Elasped Time Formatter
class TimeFormatter: Formatter {

    // MARK: CUSTOM FORMATTER
    let componentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }() // Custom Formatter, show minute & second, subseconds are hsown
    var showSubseconds = true

    override func string(for value: Any?) -> String? {
        guard let time = value as? TimeInterval else {
            return nil
        }

        guard let formattedString = componentsFormatter.string(from: time) else {
            return nil
        }

        if showSubseconds {
            // Calculate subseconds
            let hundredths = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
            let decimalSeparator = Locale.current.decimalSeparator ?? "."
            return String(format: "%@%@%0.2d", formattedString, decimalSeparator, hundredths)
        }

        return formattedString
    }

}
