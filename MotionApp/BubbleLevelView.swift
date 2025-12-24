import SwiftUI

struct BubbleLevelView: View {
    let roll: Double
    let pitch: Double
    let isLevel: Bool
    
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let radius = size / 2
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            
            ZStack {
                Circle()
                    .stroke(lineWidth: 4)
                    .foregroundColor(.gray.opacity(0.3))
                
                Circle()
                    .stroke(lineWidth: 2)
                    .frame(width: size * 0.2, height: size * 0.2)
                    .foregroundColor(isLevel ? .green : .gray)

                Path { path in
                    path.move(to: CGPoint(x: center.x - radius, y: center.y))
                    path.addLine(to: CGPoint(x: center.x + radius, y: center.y))
                    
                    path.move(to: CGPoint(x: center.x, y: center.y - radius))
                    path.addLine(to: CGPoint(x: center.x, y: center.y + radius))
                }
                .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5]))
                
                let maxAngle: Double = 45.0
                
                let xOffset = CGFloat(roll / maxAngle) * radius
                let yOffset = CGFloat(pitch / maxAngle) * radius
                
                let distance = sqrt(xOffset*xOffset + yOffset*yOffset)
                let angle = atan2(yOffset, xOffset)
                
                let clampedDist = min(distance, radius - 20)
                
                let finalX = cos(angle) * clampedDist
                let finalY = sin(angle) * clampedDist
                
                Circle()
                    .fill(isLevel ? Color.green : Color.orange)
                    .frame(width: 40, height: 40)
                    .shadow(radius: 2)
                    .offset(x: finalX, y: finalY)
                    .animation(.linear(duration: 0.1), value: finalX)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
