import SwiftUI
import SceneKit

struct ContentView: View {
    var body: some View {
        SceneKitView(imageName: "myImage") // ここでの画像名は "myimage"
            .edgesIgnoringSafeArea(.all)
    }
}

struct SceneKitView: UIViewRepresentable {
    var imageName: String // このimageNameに "myimage" が設定される

    class Coordinator: NSObject {
        var scnView: SCNView?

        // パンジェスチャーのハンドラ
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            let translation = gesture.translation(in: gesture.view)
            gesture.setTranslation(CGPoint.zero, in: gesture.view)
            rotateCamera(delta: translation)
        }

        // カメラの回転を行うメソッド
        private func rotateCamera(delta: CGPoint) {
            guard let scnView = self.scnView,
                  let cameraNode = scnView.pointOfView else {
                return
            }

            let width = scnView.bounds.width
            let height = scnView.bounds.height

            let anglePanX = Float(delta.x) / Float(width) * Float.pi * 2
            let anglePanY = Float(delta.y) / Float(height) * Float.pi * 2

            cameraNode.eulerAngles.x -= anglePanY
            cameraNode.eulerAngles.y -= anglePanX
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = SCNScene()
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = false // カメラコントロールを無効

        // 画像の読み込み確認
        if UIImage(named: imageName) != nil {
            print("画像が正しく読み込まれました。")
        } else {
            print("画像の読み込みに失敗しました。")
        }

        // 球体の作成と設定
        let sphere = SCNSphere(radius: 10)
        sphere.firstMaterial?.diffuse.contents = UIImage(named: imageName) // ここでの画像名は imageName、つまり "myimage"
        sphere.firstMaterial?.isDoubleSided = true
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(x: 0, y: 0, z: 0)
        scnView.scene?.rootNode.addChildNode(sphereNode)

        // カメラの作成と配置
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        scnView.scene?.rootNode.addChildNode(cameraNode)

        context.coordinator.scnView = scnView

        // パンジェスチャーの追加
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        scnView.addGestureRecognizer(panGesture)

        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        // SCNViewの更新処理（必要に応じて）
    }
}
