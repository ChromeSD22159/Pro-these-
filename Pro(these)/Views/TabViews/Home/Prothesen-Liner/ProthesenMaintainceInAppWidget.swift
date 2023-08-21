//
//  ProthesenMaintaince.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 09.08.23.
//

import SwiftUI

struct ProthesenMaintainceInAppWidget: View {
        
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @FetchRequest var allProthesis: FetchedResults<Prothese>
    
    @FetchRequest var allLiners: FetchedResults<Liner>
    
    @State var tabSize: CGSize = .zero
    
    init() {
        _allProthesis = FetchRequest<Prothese>(
            sortDescriptors: []
        )
        
        _allLiners = FetchRequest<Liner>(
            sortDescriptors: []
        )
    }
    
    var prothesen: [Prothese] {
        let prothesen = self.allProthesis.filter({
            $0.hasMaintage
        })
        
        return prothesen
    }

    var body: some View {
        TabView {
            if prothesen.count == 0 {
                NavigateTo({
                    NoLinerAvaible()
                        .homeScrollCardStyle(currentTheme: currentTheme)
                        .saveSize(in: $tabSize)
                        .tag(1)
                }, {
                    LinerOverview()
                })
            } else {
                ForEach(prothesen.indices, id: \.self) { index in
                    NavigateTo({
                        Prothese(prothesen[index])
                            .homeScrollCardStyle(currentTheme: currentTheme)
                            .saveSize(in: $tabSize)
                            .tag(index)
                    }, {
                        LinerOverview()
                    })
                }
            }
        }
        .frame(height: tabSize.height + 80)
        .tabViewStyle(.page)
        .padding(.vertical, -20)
        .padding(.top, -20)
        .padding(.bottom, prothesen.count == 1 ? -20 : 0)
        .padding(.bottom, prothesen.count == 0 ? -20 : 0)
    }
        
    func NoLinerAvaible() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(LocalizedStringKey("Prosthesis"))
                        .font(.body.bold())
                        .foregroundColor(currentTheme.text)
                    
                    Text(LocalizedStringKey("You have not saved any Prosthesis"))
                        .font(.caption2)
                        .foregroundColor(currentTheme.text)
                        .padding(.bottom, 6)
                }
                
                Spacer()

            }
          
            HStack(alignment: .bottom) {
                Text("No prostheses with maintenance dates available!")
                    .font(.headline.bold())
                
                Spacer()
            }
            
        }
    }
        
    func Prothese(_ prothese: Prothese) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        
                        Image(systemName: "gearshape.arrow.triangle.2.circlepath") // Image(prothese.prosthesisIcon)
                            .rotationEffect(.degrees(180))
                            .font(.body.bold())
                            .foregroundColor(currentTheme.hightlightColor)

                        Text(prothese.kind?.maintainceFor ?? LocalizedStringKey(""))
                            .font(.body.bold())
                            .foregroundColor(currentTheme.text)
                    }
                    
                    Text(prothese.kind?.maintainceSubline ?? LocalizedStringKey(""))
                        .font(.caption2)
                        .foregroundColor(currentTheme.text)
                        .padding(.bottom, 6)
                }
                
                Spacer()

            }
          
            HStack(alignment: .bottom) {
                
                let protheseDateComponents = prothese.maintainceDateComponents
                
                if prothese.nextMaintenanceDateIsInFuture {
                    Text(LocalizedStringKey("in \(protheseDateComponents.month ?? 0) Mths, \(protheseDateComponents.day ?? 0) Days"))
                        .font(.headline.bold())
                } else {
                    Text(LocalizedStringKey("Maintenance due"))
                        .font(.headline.bold())
                        .foregroundColor(prothese.nextMaintenanceDateIsInFuture ? currentTheme.text : .red)
                }
                
                Spacer()
                
                Text(prothese.MaintenanceCounterText)
                    .font(.headline.bold())
                    .foregroundColor(prothese.nextMaintenanceDateIsInFuture ? currentTheme.hightlightColor : .red)
            }
            
        }
    }
}

struct ProthesenMaintainceInAppWidget_Previews: PreviewProvider {
    static var previews: some View {
        LinerInAppWidget()
    }
}
