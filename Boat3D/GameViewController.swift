import SceneKit
// SpriteKit import might not be needed unless for UI elements not shown.
// import SpriteKit

class GameViewController: NSViewController, SCNSceneRendererDelegate { // Conform to SCNSceneRendererDelegate
    // MARK: - Properties
    
    var sceneView: SCNView!
    var scene: SCNScene!
    var boatController: BoatController!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        // Set the delegate for the scene view to receive update calls
        sceneView.delegate = self
        setupBoat()
    }
    
    // MARK: - Setup
    
    private func setupScene() {
        sceneView = SCNView(frame: view.bounds)
        sceneView.autoresizingMask = [.width, .height]
        view.addSubview(sceneView)
        
        guard let scene = SCNScene(named: "Main Scene.scn") else {
            fatalError("Failed to load Main Scene.scn")
        }
        self.scene = scene
        
        sceneView.scene = scene
        sceneView.allowsCameraControl = false // Ensure built-in camera control is off
        sceneView.showsStatistics = true
        sceneView.backgroundColor = NSColor.blue.withAlphaComponent(0.5)
        
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 200 // Adjust intensity as needed
        scene.rootNode.addChildNode(ambientLight)
        
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.color = NSColor.white
        directionalLight.light?.castsShadow = true // Optional: for shadows
        directionalLight.position = SCNVector3(x: 10, y: 20, z: 10)
        directionalLight.look(at: SCNVector3Zero) // Point towards origin
        scene.rootNode.addChildNode(directionalLight)
    }
    
    private func setupBoat() {
        guard let boatNode = scene.rootNode.childNode(withName: "Boat", recursively: true) else {
            fatalError("Failed to find Boat node in scene")
        }
        
        // Create a camera node (this is the node that has the SCNCamera component)
        let cameraEntityNode = SCNNode()
        cameraEntityNode.camera = SCNCamera()
        cameraEntityNode.camera?.zFar = 1000 // Increased zFar
        // Add camera to scene initially. BoatController will reparent it.
        scene.rootNode.addChildNode(cameraEntityNode)
        
        // Create and set up the boat controller
        // BoatController's setupCamera will handle placing cameraEntityNode correctly relative to its new pivot
        boatController = BoatController(boatNode: boatNode, cameraNode: cameraEntityNode)
        
        // Set the SCNView's pointOfView to the camera node managed by BoatController
        sceneView.pointOfView = cameraEntityNode
    }
    
    // MARK: - SCNSceneRendererDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Call the boatController's update method each frame
        boatController?.update()
    }
}
