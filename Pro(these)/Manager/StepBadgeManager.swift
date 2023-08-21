//
//  StepBadgeManager.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 14.08.23.
//

import SwiftUI

enum StepBadgeManager {

    static var stepsTotal = 0

    static var badgeManager = AppAlertBadgeManager(application: UIApplication.shared)
    
    static func updateHandler() async {
        
        self.loadData(complition: {_,_ in 
            
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            if HandlerStates.showBadgeSteps {
                badgeManager.setAlertBadge(number: stepsTotal)
            } else {
                badgeManager.resetAlertBadgetNumber()
            }
            
        })
    }
    
    static func loadData(complition: @escaping (Int, Date) -> Void) {
        let date = Date()
        HealthStoreProvider().queryDayCountbyType(date: date, type: .stepCount, completion: { steps in
            DispatchQueue.main.async {
                self.stepsTotal = Int(steps)
                HandlerStates.shared.storedSteps = Int(steps)
                HandlerStates.shared.storedStepsDate = Date()
                complition(Int(steps), date)
            }
        })
    }
    
    private static func saveCoreDataEntry(task: String, action: String, data: [BackgroundTask]) {
        let JoinedString = data
            .map{ "\($0.name),\($0.value)" } // notice the comma in the middle
            .joined(separator:"\n")

        let newTask = BackgroundTaskItem(context: PersistenceController.shared.container.viewContext)
        newTask.task = task
        newTask.action = action
        newTask.date = Date()
        newTask.data = JoinedString
        
        do {
            try? PersistenceController.shared.container.viewContext.save()
        }
    }
}


protocol BadgeNumberProvidable: AnyObject {
    var applicationIconBadgeNumber: Int { get set }
}

extension UIApplication: BadgeNumberProvidable {}

actor AppAlertBadgeManager {
    
    let application: BadgeNumberProvidable
    
    init(application: BadgeNumberProvidable) {
        self.application = application
    }
    
    @MainActor
    func setAlertBadge(number: Int) {
        application.applicationIconBadgeNumber = number
    }
    
    @MainActor
    func resetAlertBadgetNumber() {
        application.applicationIconBadgeNumber = 0
    }
}
