// App/GameViewController.swift
import SceneKit
import SwiftUI // For NSHostingView
// SpriteKit import might not be needed unless for UI elements not shown.
// import SpriteKit

class GameViewController: NSViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate { // Conform to SCNPhysicsContactDelegate
    // MARK: - Properties
    
    var sceneView: SCNView!
    var scene: SCNScene!
    var boatController: BoatController!
    var boatNode: SCNNode! // Keep a direct reference

    // Game Logic
    var gameManager: GameManager!
    var infoViewModel: InfoViewModel! // For SwiftUI

    // SwiftUI Overlay
    var hostingView: NSHostingView<GameOverlayView>!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        setupBoat() // Boat node must be available for GameManager
        
        // Initialize ViewModel and GameManager
        infoViewModel = InfoViewModel()
        // Ensure boatNode is not nil here, it's set in setupBoat()
        guard let boatNode = self.boatNode, let cameraNode = sceneView.pointOfView else { // Use sceneView.pointOfView AFTER boatController sets it
             fatalError("Boat node or camera node not found before initializing GameManager.")
        }
        gameManager = GameManager(scene: scene,
                                  boatNode: boatNode,
                                  cameraNode: cameraNode, // Pass the camera node
                                  infoViewModel: infoViewModel)

        setupSwiftUIOverlay()
        
        // Set the delegate for the scene view to receive update calls
        sceneView.delegate = self
        // Set physics contact delegate
        scene.physicsWorld.contactDelegate = self
        
        gameManager.startGame()
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        // Ensure SwiftUI overlay resizes correctly if window changes
        if let hostingView = hostingView {
            hostingView.frame = sceneView.bounds
        }
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
        sceneView.allowsCameraControl = false
        sceneView.showsStatistics = true
        sceneView.backgroundColor = NSColor.blue.withAlphaComponent(0.5)
        
        // Ensure boat physics body is set up for collision detection
        // This is already in your BoatController, but let's make sure contact masks are right.
        if let boat = scene.rootNode.childNode(withName: "Boat", recursively: true) {
             self.boatNode = boat // Store reference to boatNode
             if boat.physicsBody == nil { // If BoatController didn't add one or we need to modify
                 print("Warning: Boat physics body not set up by BoatController, ensure it's configured.")
                 // Potentially add a default one here if BoatController might not.
                 // For now, we assume BoatController does.
             }
             // This is critical for collision detection
             boat.physicsBody?.categoryBitMask = PhysicsCategory.boat
             boat.physicsBody?.contactTestBitMask = PhysicsCategory.answerZone // Tell it to notify us of contacts with answer zones
             // collisionBitMask can be all, or specific if you want it to physically collide with zones.
             // For simple detection, contactTestBitMask is key.
        } else {
            fatalError("Boat node not found in scene for physics setup.")
        }
        
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 200
        scene.rootNode.addChildNode(ambientLight)
        
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.color = NSColor.white
        directionalLight.light?.castsShadow = true
        directionalLight.position = SCNVector3(x: 10, y: 20, z: 10)
        directionalLight.look(at: SCNVector3Zero)
        scene.rootNode.addChildNode(directionalLight)
    }
    
    private func setupBoat() {
        // boatNode is already fetched and stored in setupScene.
        // If you prefer to fetch it again here, ensure it's consistent.
        guard let boatNode = self.boatNode else { // Use the class property
            fatalError("Failed to find Boat node in scene. It should have been found in setupScene.")
        }
        
        let cameraEntityNode = SCNNode()
        cameraEntityNode.camera = SCNCamera()
        cameraEntityNode.camera?.zFar = 1000
        scene.rootNode.addChildNode(cameraEntityNode) // Add to scene first
        
        boatController = BoatController(boatNode: boatNode, cameraNode: cameraEntityNode)
        sceneView.pointOfView = cameraEntityNode // This becomes the main camera
    }

    private func setupSwiftUIOverlay() {
        let overlayView = GameOverlayView(viewModel: infoViewModel, onRestartGame: { [weak self] in
            self?.gameManager.startGame()
        })
        hostingView = NSHostingView(rootView: overlayView)
        hostingView.frame = sceneView.bounds
        hostingView.autoresizingMask = [.width, .height]
        hostingView.layer?.backgroundColor = .clear // Make it transparent
        sceneView.addSubview(hostingView) // Add as subview to SCNView
    }
    
    // MARK: - SCNSceneRendererDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        boatController?.update()
        // gameManager?.updateActiveAnswerZoneTextOrientations() // No longer needed with SCNBillboardConstraint
    }

    // MARK: - SCNPhysicsContactDelegate
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB

        // Check if one is the boat and the other is an answer zone
        var boat: SCNNode?
        var answerZoneSphere: SCNNode?

        if nodeA.physicsBody?.categoryBitMask == PhysicsCategory.boat && nodeB.physicsBody?.categoryBitMask == PhysicsCategory.answerZone {
            boat = nodeA
            answerZoneSphere = nodeB
        } else if nodeB.physicsBody?.categoryBitMask == PhysicsCategory.boat && nodeA.physicsBody?.categoryBitMask == PhysicsCategory.answerZone {
            boat = nodeB
            answerZoneSphere = nodeA
        }

        if boat != nil, let zoneSphere = answerZoneSphere {
             // The zoneSphere is the SCNNode with the SCNSphere geometry inside AnswerZoneNode.
             // We need to pass its parent (the AnswerZoneNode instance) to the game manager.
             if let answerZoneContainer = zoneSphere.parent as? AnswerZoneNode {
                  // Call on main thread if it involves UI updates or significant game state changes
                  // that might conflict with physics simulation thread.
                  // GameManager methods are designed to update InfoViewModel which is @Published,
                  // so UI updates will happen automatically.
                  DispatchQueue.main.async {
                      self.gameManager.playerChoseAnswer(collidedZoneNode: answerZoneContainer)
                  }
             } else if let answerZoneContainerViaName = findAnswerZoneContainerInParents(node: zoneSphere) {
                 DispatchQueue.main.async {
                     self.gameManager.playerChoseAnswer(collidedZoneNode: answerZoneContainerViaName)
                 }
             }
        }
    }

    // Helper to find the AnswerZoneNode if the collided node is deeper
    private func findAnswerZoneContainerInParents(node: SCNNode) -> AnswerZoneNode? {
        var currentNode: SCNNode? = node
        while currentNode != nil {
            if let answerZone = currentNode as? AnswerZoneNode {
                return answerZone
            }
            currentNode = currentNode?.parent
        }
        return nil
    }
}
