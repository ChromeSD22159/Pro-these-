//
//  LinerInAppWidget.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 01.08.23.
//

import SwiftUI

struct LinerInAppWidget: View {
    
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

    var body: some View {
        TabView {
            if allLiners.count == 0 {
                NavigateTo({
                    NoLinerAvaible()
                        .homeScrollCardStyle(currentTheme: currentTheme)
                        .saveSize(in: $tabSize)
                        .tag(1)
                }, {
                    LinerOverview()
                })
            } else {
                ForEach(self.allLiners.indices, id: \.self) { index in
                    NavigateTo({
                        Liner(allLiners[index])
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
        .padding(.bottom, allLiners.count == 0 ? -20 : 0)
    }
    
    func NoLinerAvaible() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(LocalizedStringKey("Prosthesis Liner"))
                        .font(.body.bold())
                        .foregroundColor(currentTheme.text)
                    
                    Text(LocalizedStringKey("You have not saved any Prosthesis-Liners"))
                        .font(.caption2)
                        .foregroundColor(currentTheme.text)
                        .padding(.bottom, 6)
                }
                
                Spacer()

            }
          
            HStack(alignment: .bottom) {
                Text("No Prosthesis-Liner avaible!")
                    .font(.headline.bold())
                
                Spacer()
            }
            
        }
    }
    
    func Liner(_ liner: Liner) -> some View {
        
        NavigateTo({
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    
                    VStack(alignment: .leading, spacing: 6) {
                        let prothesen = liner.prothese?.allObjects as? [Prothese]
                        
                        
                        if let pro = prothesen {
                            if pro.count == 1 {
                                let prothese = pro.first
                                
                                HStack {
                                    Image("prothese.liner")
                                        .rotationEffect(.degrees(180))
                                        .font(.body.bold())
                                        .foregroundColor(currentTheme.hightlightColor)
                                    
                                    Text(prothese?.kind?.linerFor ?? LocalizedStringKey(""))
                                        .font(.body.bold())
                                        .foregroundColor(currentTheme.text)
                                }
                                
                                Text(prothese?.kind?.oneToOneOrderSubline ?? LocalizedStringKey(""))
                                    .font(.caption2)
                                    .foregroundColor(currentTheme.text)
                                    .padding(.bottom, 6)
                            }
                            
                            if pro.count > 1 {
                                                            
                                Text(LocalizedStringKey("Liners for your Prostheses"))
                                
                                Text(LocalizedStringKey("Order your liners for the your prostheses in time!"))
                                    .font(.caption2)
                                    .foregroundColor(currentTheme.text)
                                    .padding(.bottom, 6)
                            }
                        }
                        
                    }
                    
                    Spacer()

                }
              
                HStack(alignment: .bottom) {
                    
                    let linerDateComponents = liner.linerDateComponents
                    
                    if liner.nextLinerDateIsInFuture {
                        Text(LocalizedStringKey("in \(linerDateComponents.month ?? 0) Mths, \(linerDateComponents.day ?? 0) Days"))
                            .font(.headline.bold())
                    } else {
                        Text(LocalizedStringKey("Orderable"))
                            .font(.headline.bold())
                            .foregroundColor(liner.nextLinerDateIsInFuture ? currentTheme.text : .red)
                    }
                    
                    Spacer()
     
                    Text(liner.nextLinerCounterText)
                        .font(.headline.bold())
                        .foregroundColor(liner.nextLinerDateIsInFuture ? currentTheme.hightlightColor : .red)
                }
                
            }
        }, {
            LinerOverview()
        })
        
        
    }
}

struct LinerInAppWidget_Previews: PreviewProvider {
    static var previews: some View {
        LinerInAppWidget()
    }
}


