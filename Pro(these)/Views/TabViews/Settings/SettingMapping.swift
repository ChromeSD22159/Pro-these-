//
//  SettingMapping.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 27.04.23.
//

import SwiftUI
// MARK: DEV TESTING Items
struct MoreViewList: Identifiable {
    var id: String { titel }
    var titel: String
    var backgroundGradient: LinearGradient
    var foregroundColor: Color
    
    static let items = [
        MoreViewList(titel: "Schrittzähler", backgroundGradient: AppConfig().backgroundGradient, foregroundColor: AppConfig().foreground),
        MoreViewList(titel: "Terminplaner", backgroundGradient: AppConfig().backgroundGradient, foregroundColor: AppConfig().foreground),
        MoreViewList(titel: "Timer", backgroundGradient: AppConfig().backgroundGradient, foregroundColor: AppConfig().foreground),
        MoreViewList(titel: "Liner", backgroundGradient: AppConfig().backgroundGradient, foregroundColor: AppConfig().foreground),
        MoreViewList(titel: "Planer", backgroundGradient: AppConfig().backgroundGradient, foregroundColor: AppConfig().foreground),
    ]
}

// MARK: Settings Items
struct Settings: Identifiable {
    var id: String { titel }
    var titel: String
    var icon: String
    var options: [Options]
    
    static var items = [
        /*
        Settings( // checked
            titel: "Fitness Statistik",
            icon: "chart.bar.xaxis",
            options: [
            ]
        ),
        
        Settings( // checked
            titel: "Prothesen Recorder",
            icon: "figure.walk",
            options: [
                Options(titel: "1", icon: "stopwatch", desc: "Prozentuale Tragezeit zum Durchschnitt", info: "Zeige die Prozentuale Tragezeit im Vergleich zur Durchschnittlichen Tragezeit.", binding: AppConfig().$ShowToDayRecordingPercentageToAvg)
            ]),
        */
        
        Settings( // checked
            titel: "Terminplaner",
            icon: "calendar",
            options: [
                Options(titel: "1", icon: "exclamationmark.circle",  desc: "Zeige alle abgelaufene Termine Sortiert an.", info: "Zeige alle abgelaufene Termine Sortiert an.", binding: AppConfig().$showPastEvents),
                Options(titel: "2", icon: "repeat.circle", desc: "Zeige alle Termine Sortiert an.", info: "Zeige alle Termine Sortiert an.", binding: AppConfig().$showAllEvents),
               // Options(titel: "3", icon: "calendar", desc: "Priorisiert Listenansicht", info: "Diese Einstellung legt die standartisierte Erscheinung der Termine als Übersicht fest.", binding: AppConfig.shared.$EventShowList),
               // Options(titel: "4", icon: "calendar", desc: "Priorisiert Kalendarische-Ansicht", info: "Diese Einstellung legt die standartisierte Erscheinung der Termine als Übersicht fest.", binding: AppConfig.shared.$EventShowCalendar)
            ]),
        
        Settings( // new
            titel: "Sicherheit",
            icon: "lock.square",
            options: [
                Options(titel: "1", icon: "stopwatch", desc: "Schütze deine Daten mit FaceID", info: "Aktiviere FaceID Prüfung wenn App startet.", binding: AppConfig.shared.$faceID, inVisible: true),
            ]),
    ]
    
}

struct Options : Identifiable {
    var id: String { titel }
    var titel: String
    let icon: String
    var desc: String
    var info: String
    var binding: Binding<Bool>
    var inVisible: Bool?
}
