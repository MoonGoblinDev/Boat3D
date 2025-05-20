import SceneKit
import SpriteKit 

class BoatController: NSObject {
    // MARK: - Properties
    
    var boatNode: SCNNode
    var cameraNode: SCNNode // This is the node with the SCNCamera component
    
    private var cameraPivotNode: SCNNode! // New: A pivot node for smooth camera transforms
    
    // Camera follow settings
    private let cameraDistance: Float = 15.0
    private let cameraHeight: Float = 8.0
    private let cameraPositionSmoothingFactor: Float = 0.1 // Lower value = smoother/slower
    private let cameraOrientationSmoothingFactor: Float = 0.05 // Lower value = smoother/slower
    
    // Physics properties
    private let rotationForce: Float = 2.0
    private let forwardForce: Float = 5.0
    
    // Paddling timer control
    private var canPaddleLeft = true
    private var canPaddleRight = true
    private let paddlingInterval: TimeInterval = 0.1
    
    // Keep track of key states
    private var leftKeyDown = false
    private var rightKeyDown = false
    
    // MARK: - Initialization
    
    init(boatNode: SCNNode, cameraNode: SCNNode) {
        self.boatNode = boatNode
        self.cameraNode = cameraNode
        
        super.init()
        
        setupPhysics()
        setupCamera() // setupCamera will now create and manage cameraPivotNode
        setupKeyHandling()
    }
    
    // MARK: - Setup
    
    private func setupPhysics() {
        // Create a physics body for the boat
        let shape = SCNPhysicsShape(node: boatNode, options: [SCNPhysicsShape.Option.keepAsCompound: true])
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        
        physicsBody.mass = 10.0
        physicsBody.friction = 0.1
        physicsBody.restitution = 0.2
        physicsBody.angularDamping = 0.1 // Increased angular damping can help stabilize
        physicsBody.damping = 0.1
        physicsBody.isAffectedByGravity = false
        boatNode.physicsBody = physicsBody
    }
    
    private func setupCamera() {
        // Create a new pivot node. This pivot will smoothly follow the boat.
        cameraPivotNode = SCNNode()
        
        // Add the camera pivot to the scene. It should be at the same level as the boat or camera.
        // We assume cameraNode is already in the scene, so we use its parent (likely scene's rootNode).
        guard let sceneRoot = cameraNode.parent else {
            fatalError("Camera node must be part of the scene graph before BoatController is initialized.")
        }
        sceneRoot.addChildNode(cameraPivotNode)
        
        // Reparent the actual cameraNode to be a child of our new cameraPivotNode.
        cameraNode.removeFromParentNode()
        cameraPivotNode.addChildNode(cameraNode)
        
        // Position the camera relative to the pivot (behind and above).
        cameraNode.position = SCNVector3(x: 0, y: CGFloat(cameraHeight), z: CGFloat(cameraDistance))
        
        // Make the camera look towards a point slightly in front of the pivot's origin.
        // (Pivot origin represents the boat's position).
        cameraNode.look(at: SCNVector3(0, 0, -cameraDistance * 0.25)) // Look at a point relative to the pivot
        
        // Initialize pivot's transform to match the boat's current transform.
        // Use presentation node if boat has physics, otherwise transform is fine.
        if boatNode.physicsBody != nil {
            cameraPivotNode.worldPosition = boatNode.presentation.worldPosition
            cameraPivotNode.worldOrientation = boatNode.presentation.worldOrientation
        } else {
            cameraPivotNode.worldPosition = boatNode.worldPosition
            cameraPivotNode.worldOrientation = boatNode.worldOrientation
        }
    }
    
    private func setupKeyHandling() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event -> NSEvent? in
            guard let self = self else { return event }
            if self.handleKeyDown(event) { return nil }
            return event
        }
        
        NSEvent.addLocalMonitorForEvents(matching: .keyUp) { [weak self] event -> NSEvent? in
            guard let self = self else { return event }
            if self.handleKeyUp(event) { return nil }
            return event
        }
    }
    
    // MARK: - Key Handling (Unchanged)
    private func handleKeyDown(_ event: NSEvent) -> Bool {
        switch event.keyCode {
        case 123: // Left arrow key
            leftKeyDown = true
            paddleLeft()
            return true
        case 124: // Right arrow key
            rightKeyDown = true
            paddleRight()
            return true
        default:
            return false
        }
    }
    
    private func handleKeyUp(_ event: NSEvent) -> Bool {
        switch event.keyCode {
        case 123: // Left arrow key
            leftKeyDown = false
            return true
        case 124: // Right arrow key
            rightKeyDown = false
            return true
        default:
            return false
        }
    }
    
    // MARK: - Paddling Controls (Unchanged, uses improved applyForwardForce)
    private func paddleLeft() {
        guard canPaddleLeft else { return }
        applyRotation(direction: -1)
        applyForwardForce(paddleSide: .left)
        canPaddleLeft = false
        DispatchQueue.main.asyncAfter(deadline: .now() + paddlingInterval) { [weak self] in
            self?.canPaddleLeft = true
            if self?.leftKeyDown == true { self?.paddleLeft() }
        }
    }
    
    private func paddleRight() {
        guard canPaddleRight else { return }
        applyRotation(direction: 1)
        applyForwardForce(paddleSide: .right)
        canPaddleRight = false
        DispatchQueue.main.asyncAfter(deadline: .now() + paddlingInterval) { [weak self] in
            self?.canPaddleRight = true
            if self?.rightKeyDown == true { self?.paddleRight() }
        }
    }
    
    // MARK: - Physics
    
    private func applyRotation(direction: Float) {
        let torque = SCNVector4(0, 1, 0, direction * rotationForce) // Axis-angle (y-axis rotation)
        boatNode.physicsBody?.applyTorque(torque, asImpulse: true)
    }
    
    private enum PaddleSide {
        case left
        case right
    }
    
    // Improved applyForwardForce for more realistic sideways push
    private func applyForwardForce(paddleSide: PaddleSide) {
        let boatPresentation = boatNode.presentation // Use presentation node for physics objects

        // Get boat's local forward and right vectors in world space
        let worldForward = boatPresentation.convertVector(SCNVector3(0, 0, -1), to: nil)
        let worldRight   = boatPresentation.convertVector(SCNVector3(1, 0, 0), to: nil)
        
        // Determine side push scale: left paddle pushes boat slightly to its right, right paddle to its left
        let sidePushScale: CGFloat = paddleSide == .left ? 0.15 : -0.15 // Adjust this factor as needed

        // Combine forward thrust with a sideways component relative to the boat
        var combinedDirection = worldForward + (worldRight * sidePushScale)
        
        // We want the force to be primarily in the horizontal (XZ) plane for a boat
        combinedDirection.y = 0
        
        let normalizedForceDirection = combinedDirection.normalized()

        // If the direction is very small (e.g., vectors cancelled out), fallback or do nothing
        if normalizedForceDirection.length() < 0.001 {
            var pureForward = worldForward
            pureForward.y = 0 // Ensure pure forward is also horizontal
            if pureForward.length() < 0.001 { return } // Boat is pointing straight up/down, no sensible horizontal force

            let fallbackForce = pureForward.normalized() * CGFloat(forwardForce)
            boatNode.physicsBody?.applyForce(fallbackForce, asImpulse: true)
            return
        }

        let force = normalizedForceDirection * CGFloat(forwardForce)
        boatNode.physicsBody?.applyForce(force, asImpulse: true)
    }

    // MARK: - Update Method (Called every frame)
    
    public func update() { // deltaTime could be passed here for frame-rate independent smoothing
        guard let pivot = cameraPivotNode, boatNode.physicsBody != nil else { return }

        // --- Smoothly update camera pivot's position to follow the boat ---
        // Target position is the boat's presentation node's world position
        let targetPosition = boatNode.presentation.worldPosition
        pivot.worldPosition = SCNVector3.lerp(start: pivot.worldPosition,
                                              end: targetPosition,
                                              t: cameraPositionSmoothingFactor)

        // --- Smoothly update camera pivot's orientation to follow the boat ---
        // Target orientation is the boat's presentation node's world orientation
        let targetOrientation = boatNode.presentation.worldOrientation
        // Original line:
        // pivot.worldOrientation = SCNQuaternion.slerp(pivot.worldOrientation,
        //                                              targetOrientation,
        //                                              amount: cameraOrientationSmoothingFactor)

        // Need to convert SCNQuaternion to GLKQuaternion and back
        let startQuat = GLKQuaternionMake(Float(pivot.worldOrientation.x),
                                          Float(pivot.worldOrientation.y),
                                          Float(pivot.worldOrientation.z),
                                          Float(pivot.worldOrientation.w))

        let endQuat = GLKQuaternionMake(Float(targetOrientation.x),
                                        Float(targetOrientation.y),
                                        Float(targetOrientation.z),
                                        Float(targetOrientation.w))

        let slerpedQuat_GLK = GLKQuaternionSlerp(startQuat, endQuat, cameraOrientationSmoothingFactor)

        pivot.worldOrientation = SCNVector4(x: CGFloat(slerpedQuat_GLK.x),
                                            y: CGFloat(slerpedQuat_GLK.y),
                                            z: CGFloat(slerpedQuat_GLK.z),
                                            w: CGFloat(slerpedQuat_GLK.w))
    }
}
