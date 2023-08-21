//
//  WeeklyReportsWidget.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 14.08.23.
//

import SwiftUI

struct WeeklyReportsWidget: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @FetchRequest private var allReports: FetchedResults<Report>
    
    private var lastReport: Report? {
       return self.allReports.sorted(by: { $0.created ?? Date() < $1.created ?? Date() }).last
    }
    
    private var background: Color
    
    init(background: Color) {
        _allReports = FetchRequest<Report>(
            sortDescriptors: [NSSortDescriptor(key: "created", ascending: false)]
        )
        
        self.background = background
    }
    
    var body: some View {
        if allReports.count > 0 {
            NavigateTo({
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(LocalizedStringKey("Weekly progress report"))
                                .font(.body.bold())
                                .foregroundColor(currentTheme.text)
                            
                            Text(LocalizedStringKey("Your weekly progress compared to the previous week."))
                                .font(.caption2)
                                .foregroundColor(currentTheme.text)
                                .padding(.bottom, 6)
                        }
                        
                        Spacer()

                    }
                  
                    HStack(alignment: .bottom) {
                        Text("All reports")
                            .font(.headline.bold())
                            .foregroundColor(background)

                        Spacer()
                        
                        HStack {
                            Text("Last report:")
                                .font(.footnote)
                                .foregroundColor(currentTheme.textGray)
                            
                            Text(lastReport?.created?.dateFormatte(date: "dd.MM.yyyy", time: "").date ?? Date().dateFormatte(date: "dd.MM.yyyy", time: "").date)
                                .font(.headline.bold())
                                .foregroundColor(background)
                        }
                    }
                    
                }
                .homeScrollCardStyle(currentTheme: currentTheme)
            }, {
                WeeklyReports(background: currentTheme.hightlightColor)
            })
        } 
    }
}

struct WeeklyReportsWidget_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyReportsWidget(background: .blue)
    }
}
