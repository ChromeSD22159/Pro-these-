//
//  ProthesenWearingCounter.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 20.08.23.
//

import SwiftUI

struct ProthesenWearingCounter: View {
    
    @FetchRequest var prothesen: FetchedResults<Prothese>
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @State var screenWidth:CGFloat = 0
    
    private var type: ProthesenWearingCounter.type
    
    init(type: ProthesenWearingCounter.type) {
        self.type = type
        _prothesen = FetchRequest<Prothese>(sortDescriptors: [])
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            HStack {
                Text( self.type.titel )
                    .font(.body.bold())
                    .foregroundColor(currentTheme.text)

                Spacer()
            }
            
            HStack {
                Text( self.type.subTitel )
                    .font(.caption2)
                    .foregroundColor(currentTheme.text)
                    .padding(.bottom, 6)
                
                Spacer()
            }
  
            VStack(alignment: .center) {
                ForEach(prothesen.indices, id: \.self) { index in
                    ProthesenCard(type: self.type, delay: (Double(index + 1) / 10 * 2), prothese: prothesen[index])
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
    
    enum type: Int, Codable, Hashable {
        case week = 6
        case twoWeeks = 13
        case month = 30
        
        var firstDate: Date {
            return Calendar.current.date(byAdding: .day, value: -(self.rawValue), to: Date())!.startEndOfDay().start
        }
        
        var dayCount: Int {
            self.rawValue + 1
        }
        
        var titel: LocalizedStringKey {
            "Worn prostheses"
        }
        
        var subTitel: LocalizedStringKey {
            "Prostheses you have worn in the last \(self.dayCount) days."
        }
    }
}

struct ProthesenCard:View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @State var animationWidth:CGFloat = 0
    
    var type: ProthesenWearingCounter.type
    
    var delay: Double
    
    @State private var screenWidth: CGFloat = 0
    
    @ObservedObject var prothese: FetchedResults<Prothese>.Element
    
    var feelings: Int {
        let feelings = self.prothese.feelings?.allObjects as? [Feeling] ?? []

        let filtered = feelings.filter({
            return $0.date ?? Date() > type.firstDate
         })
        
        let grouped = Dictionary(grouping: filtered, by: { (item) -> Date in
            return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: item.date!))!
        })

        return grouped.count
    }
    
    var body: some View {
        ZStack {
            
            Rectangle()
                .fill(.gray.opacity(0.2))
                .frame(width: screenWidth)
                .cornerRadius(10)
            
            HStack() {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                currentTheme.hightlightColor.opacity(1),
                                currentTheme.hightlightColor.opacity(0.6)
                            ],
                            startPoint: .trailing,
                            endPoint: .leading
                        )
                    )
                    .frame(width: animationWidth)
                    .cornerRadius(10)
                
                Spacer(minLength: 0.01)
            }
            .background(GeometryReader { view -> Color in
                DispatchQueue.main.async {
                   self.screenWidth = view.size.width
                }
                return Color.clear
            })

            MoodSmilyStack(prothese: prothese.prosthesisKind.localizedstring().prefix(1) + "P" ,image: prothese.prosthesisIcon)
            
            PercentStack(count: feelings)
            
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .onAppear {
            self.animationWidth = 0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (0.5 + delay) ) {
                withAnimation(.easeInOut) {

                    let newWidth = screenWidth / CGFloat(type.dayCount) * CGFloat(feelings)
                    
                    self.animationWidth = newWidth

                }
           }
        }
        .onDisappear{
            self.animationWidth = 0
        }
    }
    
    @ViewBuilder
    func MoodSmilyStack(prothese: String, image: String) -> some View {
        HStack {
            
            VStack(alignment: .center, spacing: 3) {
                Image(image)
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(currentTheme.hightlightColor, currentTheme.textGray)
                    .blendMode(.difference)

                Text("\(prothese)")
                    .font(.system(size: 8, weight: .black))
                    .foregroundColor(currentTheme.hightlightColor)
                    .blendMode(.difference)
            }
            
            Spacer()
            
        }
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder
    func PercentStack(count: Int) -> some View {
        HStack {
            Spacer()
            
            Text("\(count)x")
                .font(.headline.bold())
                .foregroundColor(currentTheme.hightlightColor)
                .blendMode(.difference)
            
            Spacer()
        }
        .padding(.horizontal, 10)
    }
}


struct ProtheseDiagramItem {
    var prothese: String
    var image: String
    var data: [(id: UUID, value: Int, date: Date)]
}

struct ProthesenWearingCounter_Previews: PreviewProvider {
    static var previews: some View {
        ProthesenWearingCounter(type: .week)
    }
}
