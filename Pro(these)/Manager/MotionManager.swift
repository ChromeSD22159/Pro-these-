//
//  MotionManager.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 16.10.23.
//

import SwiftUI

class MotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    
    @Published var isWalking = false
    
    init() {
        startMotionUpdates()
    }
    
    private func startMotionUpdates() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
                guard let data = data, error == nil else { return }
                
                let acceleration = sqrt(data.acceleration.x * data.acceleration.x +
                                        data.acceleration.y * data.acceleration.y +
                                        data.acceleration.z * data.acceleration.z)
                
                // You can adjust this threshold based on your requirements
                let walkingThreshold: Double = 1.0
                
                DispatchQueue.main.async {
                    self?.isWalking = acceleration > walkingThreshold
                }
            }
        }
    }
}
