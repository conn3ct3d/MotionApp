import SceneKit
import SwiftUI

struct SceneKitView: UIViewRepresentable {
    @ObservedObject var vm: MotionViewModel

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = SCNScene()
        scnView.allowsCameraControl = false
        scnView.backgroundColor = UIColor.clear
        scnView.autoenablesDefaultLighting = true
        
// cube
        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1)
        box.firstMaterial?.diffuse.contents = UIColor.systemBlue
        let boxNode = SCNNode(geometry: box)
        boxNode.name = "cube"
        scnView.scene?.rootNode.addChildNode(boxNode)
        
        // camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
        scnView.scene?.rootNode.addChildNode(cameraNode)
        
        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        guard let cubeNode = scnView.scene?.rootNode.childNode(withName: "cube", recursively: false) else { return }
        
        // convert Euler Angles (Roll/Pitch/Yaw) from deg to rad for SceneKit
        let rollRad = Float(vm.rollDeg * .pi / 180)
        let pitchRad = Float(vm.pitchDeg * .pi / 180)
        let yawRad = Float(vm.yawDeg * .pi / 180)
        
        // update rotation
        cubeNode.eulerAngles = SCNVector3(pitchRad, yawRad, rollRad)
    }
}
