//
//  ChartSnapView.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 21.05.23.
//

import SwiftUI

struct ChartSnapView<Content:View, T: Identifiable>: View {
    var content: (T) -> Content
    var list: [T]
    
    var spacing: CGFloat
    var trailingSpace: CGFloat
    @Binding var index: Int
    
    @EnvironmentObject var vm: WorkoutStatisticViewModel
    
    init(spacing: CGFloat = 15,  trailingSpace: CGFloat = 100,  index: Binding<Int>, list: [T], content: @escaping(T) -> Content ){
        self.list = list
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self._index = index
        self.content = content
    }
    
    @GestureState var offset: CGFloat = 0
    @State var currentIndex: Int = 0
   
    var body: some View {
        GeometryReader { proxy in
            
            let width = proxy.size.width - (trailingSpace - spacing)
            let adjustMentWidth = (trailingSpace / 2) - spacing
            HStack(spacing: spacing) {
                ForEach(list) { item in
                    content(item)
                        .frame(width: proxy.size.width - trailingSpace)
                }
            }
            .padding(.horizontal, spacing)
            .offset(x: (CGFloat(currentIndex) * -proxy.size.width) + (currentIndex != 0 ? adjustMentWidth : 0 ) )
            .gesture(
                DragGesture()
                    .updating($offset, body: { value, out, _ in
                        out = value.translation.width
                    })
                    .onEnded({ value in
                        // Updating current Index
                        let offsetX = value.translation.width
                         
                        // convert translation into progress (0-1)
                        let progress = -offsetX / width
                        let roundIndex = progress.rounded()
                        
                        
                        progress.sign == .minus ?  (currentIndex - 1) : (currentIndex + 1)
                        currentIndex = max(min(currentIndex + Int(round(roundIndex)), list.count - 1),0)
                        
                        currentIndex = index
                    })
                    .onChanged({ value in
                        // Updating current Index
                        let offsetX = value.translation.width
                        
                        // convert translation into progress (0-1)
                        let progress = -offsetX / width
                        let roundIndex = progress.rounded()
                        index = max(min(currentIndex + Int(round(roundIndex)), list.count - 1),0)
                        //progress.sign == .minus ? index - 1 : index + 1
                        changeSelectedValues(currentIndex)
                    })
            )
           
        }
        .animation(.easeInOut, value: offset == 0)
        .onAppear{
            currentIndex = index
        }
        .onChange(of: index, perform: { value in
            currentIndex = value
            
            changeSelectedValues(value)
        })
    }
    
    func changeSelectedValues(_ index: Int){
        // Order Collegtion by week desc
        let step = vm.CollectionWeeklySteps.sorted { $0.weekNr < $1.weekNr }
        let dist = vm.CollectionWeeklyDistanz.sorted { $0.weekNr < $1.weekNr }
        
        // if new SelectedDate in this week, set this Date or find the first day of the selected week
        vm.currentDay = Calendar.current.isDateInThisWeek(step[index].data.first?.date ?? Date()) ? Date() : step[index].data.first?.date ?? Date()
        
        // Set AVGs by Week
        vm.selectedAvgSteps =    Double(step[index].avg)
        vm.selectedAvgDistance = Double(dist[index].avg)
    }
}
