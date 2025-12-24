import SwiftUI

struct ContentView: View {
    @StateObject private var vm = MotionViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Digital Bubble")
                .font(.headline)
                .padding(.top)
            
            if let error = vm.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(4)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(4)
            }
            
            BubbleLevelView(
                roll: vm.rollDeg,
                pitch: vm.pitchDeg,
                isLevel: vm.isLevel
            )
            .padding()
            
            VStack(alignment: .leading, spacing: 5) {
                dataRow(label: "Roll (X):", value: vm.rollDeg)
                dataRow(label: "Pitch (Y):", value: vm.pitchDeg)
                dataRow(label: "Yaw (Z):", value: vm.yawDeg)
                Text(String(format: "Freq: %.1f Hz", vm.sampleHz))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            
            // Controls
            HStack {
                Button(action: {
                    vm.isDemoMode.toggle()
                    vm.startUpdates() // reset
                }) {
                    VStack {
                        Image(systemName: vm.isDemoMode ? "play.rectangle.fill" : "iphone")
                        Text(vm.isDemoMode ? "Demo" : "Sensor")
                    }
                }
                .padding()
                
                Divider().frame(height: 30)
                
                Menu {
                    Button("30 Hz") { vm.updateInterval = 1.0/30.0; vm.startUpdates() }
                    Button("60 Hz") { vm.updateInterval = 1.0/60.0; vm.startUpdates() }
                    Button("100 Hz") { vm.updateInterval = 1.0/100.0; vm.startUpdates() }
                } label: {
                    VStack {
                        Image(systemName: "speedometer")
                        Text("Hz Rate")
                    }
                }
                .padding()
            }
            
            Spacer()
        }
        // Lifecycle Management
        .onAppear {
            vm.startUpdates()
        }
        .onDisappear {
            vm.stopUpdates()
        }
    }
    
    private func dataRow(label: String, value: Double) -> some View {
        HStack {
            Text(label).fontWeight(.bold)
            Spacer()
            Text(String(format: "%.2f°", value))
                .font(.system(.body, design: .monospaced))
        }
    }
}
