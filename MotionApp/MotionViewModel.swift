import SwiftUI
import CoreMotion
import Combine

@MainActor
class MotionViewModel: ObservableObject {
    @Published var rollDeg: Double = 0.0
    @Published var pitchDeg: Double = 0.0
    @Published var yawDeg: Double = 0.0
    @Published var isLevel: Bool = false
    @Published var sampleHz: Double = 0.0
    @Published var errorMessage: String? = nil
    
    @Published var updateInterval: Double = 1.0 / 60.0
    @Published var smoothingAlpha: Double = 0.15
    @Published var isDemoMode: Bool = false
    
    private let motionManager = CMMotionManager()

    private var demoTask: Task<Void, Never>?
    
    private var lastUpdateTime: TimeInterval = 0
    private var rawRoll: Double = 0
    private var rawPitch: Double = 0
    private var rawYaw: Double = 0
    
    
    func startUpdates() {
        stopUpdates()
        errorMessage = nil
        
        if isDemoMode {
            startDemoMode()
            return
        }
        
        guard motionManager.isDeviceMotionAvailable else {
            errorMessage = "No Sensors Available. Displaying Demo"
            isDemoMode = true
            startDemoMode()
            return
        }
        
        motionManager.deviceMotionUpdateInterval = updateInterval
        
        motionManager.startDeviceMotionUpdates(
            using: .xArbitraryZVertical,
            to: .main
        ) { [weak self] (motion, error) in
            guard let self = self else { return }
            if let motion = motion {
                self.processMotionData(motion)
            } else if let error = error {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
        
        demoTask?.cancel()
        demoTask = nil
    }
    
    
    private func processMotionData(_ motion: CMDeviceMotion) {
        let newRoll = motion.attitude.roll * (180 / .pi)
        let newPitch = motion.attitude.pitch * (180 / .pi)
        let newYaw = motion.attitude.yaw * (180 / .pi)
        
        self.rawRoll = (smoothingAlpha * newRoll) + ((1 - smoothingAlpha) * self.rawRoll)
        self.rawPitch = (smoothingAlpha * newPitch) + ((1 - smoothingAlpha) * self.rawPitch)
        self.rawYaw = (smoothingAlpha * newYaw) + ((1 - smoothingAlpha) * self.rawYaw)
        
        self.rollDeg = self.rawRoll
        self.pitchDeg = self.rawPitch
        self.yawDeg = self.rawYaw
        
        self.isLevel = abs(self.rollDeg) < 3.0 && abs(self.pitchDeg) < 3.0
        
        let now = Date().timeIntervalSince1970
        if lastUpdateTime != 0 {
            let delta = now - lastUpdateTime
            self.sampleHz = 1.0 / delta
        }
        lastUpdateTime = now
    }
    
    
    private func startDemoMode() {
        demoTask?.cancel()
        
        demoTask = Task {
            var tick = 0.0
            
            while !Task.isCancelled {
                tick += 0.1
                let simRoll = sin(tick) * 10
                let simPitch = cos(tick * 0.7) * 10
                
                self.rollDeg = simRoll
                self.pitchDeg = simPitch
                self.yawDeg = (self.yawDeg + 0.5).truncatingRemainder(dividingBy: 360)
                
                self.isLevel = abs(simRoll) < 3.0 && abs(simPitch) < 3.0
                self.sampleHz = 1.0 / self.updateInterval

                let nanoseconds = UInt64(self.updateInterval * 1_000_000_000)
                try? await Task.sleep(nanoseconds: nanoseconds)
            }
        }
    }
}
