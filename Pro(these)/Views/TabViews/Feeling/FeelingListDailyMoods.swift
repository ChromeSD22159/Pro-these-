//
//  FeelingListDailyMoods.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 24.05.23.
//

import SwiftUI

struct FeelingListDailyMoods: View {
    @EnvironmentObject var cal: MoodCalendar
    @FetchRequest(sortDescriptors: []) var feelings: FetchedResults<Feeling>
    var body: some View {
        ScrollView(showsIndicators: false) {
            /// Daily Feelings
            VStack(spacing: 20) {
                Text("Feeling")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                let feeling = feelings.filter{ cal.isSameDay(d1: $0.date ?? Date(), d2: cal.currentDate) }
                
                if feeling.count > 0 {
                    ForEach(feeling, id: \.id){ feeling in
                        HStack{
                            Text(feeling.name ?? "UnknownName")
                            Spacer()
                            Text(feeling.date ?? Date(), style: .date)
                            Text(feeling.date ?? Date(), style: .time)
                        }
                    }
                } else {
                    Text("No Feeling Found")
                }
            }
            .padding()
            .padding(.top, 25)
        }
    }
}

struct FeelingListDailyMoods_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Theme.blue.gradientBackground(nil).ignoresSafeArea()
            
            FeelingListDailyMoods()
                .environmentObject(AppConfig())
                .environmentObject(TabManager())
                .environmentObject(HealthStorage())
                .environmentObject(PushNotificationManager())
                .environmentObject(EventManager())
                .environmentObject(MoodCalendar())
                .environmentObject(WorkoutStatisticViewModel())
                .environmentObject(PainViewModel())
                .environmentObject(StateManager())
                .environmentObject(EntitlementManager())
                .defaultAppStorage(UserDefaults(suiteName: "group.FK.Pro-these-")!)
                .colorScheme(.dark)
        }
    }
}
