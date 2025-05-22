import SwiftUI
import SceneKit // Import SceneKit for 3D models

// 1. Player Model (simple, as all are ready in the image)
struct Player: Identifiable {
    let id: String
    let name: String
    let color: Color
}

// Sample data based on the image
let players: [Player] = [
    Player(id: "1", name: "Player 1", color: .red),
    Player(id: "2", name: "Player 2", color: .blue),
    Player(id: "3", name: "Player 3", color: .green),
    Player(id: "4", name: "Player 4", color: .yellow)
]

// 2. Bear 3D Model View
struct BearModelView: View {
    let playerColor: Color
    private var scene: SCNScene?

    init(playerColor: Color) {
        self.playerColor = playerColor
        self.scene = Self.setupScene(with: playerColor)
    }

    private static func setupScene(with swiftUIColor: Color) -> SCNScene? {
        // 1. Load the main model scene (Bear.dae) from art.scnassets
        // For SCNScene, you can often refer to the path within the .scnassets folder directly.
        guard let modelScene = SCNScene(named: "art.scnassets/Bear/Bear.dae") else {
            print("Error: Could not load Bear.dae from art.scnassets.")
            // Try a fallback if the above doesn't work due to project structure nuance
            // This might be needed if "art.scnassets" is just a group and not a true asset catalog reference
            if let modelURL = Bundle.main.url(forResource: "Bear", withExtension: "dae", subdirectory: "art.scnassets"),
               let sceneFromURL = try? SCNScene(url: modelURL, options: nil) {
                print("Successfully loaded Bear.dae using Bundle.main.url with subdirectory.")
                return processScene(sceneFromURL, with: swiftUIColor) // Call a helper to process the loaded scene
            } else {
                print("Also failed to load Bear.dae using Bundle.main.url from art.scnassets.")
                return nil
            }
        }
        
        // If SCNScene(named:) worked, proceed to process it
        return processScene(modelScene, with: swiftUIColor)
    }

    // Helper function to process the loaded scene (apply color, animation, etc.)
    private static func processScene(_ modelScene: SCNScene, with swiftUIColor: Color) -> SCNScene? {
        // 2. Find the main node to color and animate.
        var nodeToModify: SCNNode? = nil
        
        func findMainNode(_ node: SCNNode) -> SCNNode? {
            // Prioritize nodes with "armature" in their name, common for animated characters.
            if (node.name ?? "").lowercased().contains("armature") {
                return node
            }
            // Otherwise, look for the first node with geometry.
            if node.geometry != nil {
                return node
            }
            for child in node.childNodes {
                if let found = findMainNode(child) {
                    return found
                }
            }
            return nil
        }

        // Try finding a specific node first, then fallback to root or first child.
        nodeToModify = findMainNode(modelScene.rootNode) ?? modelScene.rootNode.childNodes.first ?? modelScene.rootNode
        
        guard let finalNodeToModify = nodeToModify else {
            print("Error: Could not find a suitable node in Bear.dae.")
            return modelScene // Return scene as is, maybe something shows up
        }

        // 3. Apply color to the model's materials
        #if os(macOS)
        let scnColor = NSColor(swiftUIColor)
        #else
        let scnColor = UIColor(swiftUIColor)
        #endif

        finalNodeToModify.enumerateHierarchy { (node, _) in
            if let geometry = node.geometry {
                geometry.materials.forEach { material in
                    material.diffuse.contents = scnColor
                    material.lightingModel = .phong
                    //material.specular.contents = UIColor.gray
                    material.shininess = 2.0
                }
            }
        }

        // 4. Load and apply animation from idle.dae located in art.scnassets
        // For SCNSceneSource, we generally need a URL.
        if let animURL = Bundle.main.url(forResource: "idle", withExtension: "dae", subdirectory: "art.scnassets/Bear"),
           let animSource = SCNSceneSource(url: animURL, options: nil) {
            
            let animationIdentifiers = animSource.identifiersOfEntries(withClass: CAAnimation.self)
            if let firstAnimID = animationIdentifiers.first {
                if let animation = animSource.entryWithIdentifier(firstAnimID, withClass: CAAnimation.self) {
                    animation.repeatCount = .infinity
                    animation.fadeInDuration = 0.3
                    animation.fadeOutDuration = 0.3
                    
                    // Ensure animation is applied to the correct node
                    // If finalNodeToModify is an "Armature" type node, animations usually go on it or its direct parent.
                    // If finalNodeToModify is a mesh, the animation might need to go on a parent armature node.
                    // For simplicity, we're applying to finalNodeToModify. If it's the root, and animation targets a sub-node,
                    // it might not work as expected. SceneKit usually retargets animations if the hierarchy matches.
                    finalNodeToModify.addAnimation(animation, forKey: "idleAnimation")
                    print("Idle animation applied to node: \(finalNodeToModify.name ?? "Unnamed Node")")
                } else {
                    print("Error: Could not load animation with ID '\(firstAnimID)' from idle.dae.")
                }
            } else {
                print("Error: No animations found in idle.dae within art.scnassets.")
            }
        } else {
            print("Error: Could not get URL for idle.dae from art.scnassets or create SCNSceneSource.")
        }

        // 5. Camera Setup
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        let (minBounds, maxBounds) = finalNodeToModify.presentation.boundingBox // Use presentation for animated nodes
        let modelWidth = maxBounds.x - minBounds.x
        let modelHeight = maxBounds.y - minBounds.y
        let modelDepth = maxBounds.z - minBounds.z
        let modelCenterX = minBounds.x + modelWidth / 2
        let modelCenterY = minBounds.y + modelHeight / 2
        let modelCenterZ = minBounds.z + modelDepth / 2

        let camX = modelCenterX
        let camY = modelCenterY + modelHeight * 0.2 // Slightly higher Y for better view
        let camZ = modelCenterZ + max(modelHeight, modelWidth) * 2.0 // Adjust distance factor
        
        cameraNode.position = SCNVector3(camX, camY, camZ)
        cameraNode.look(at: SCNVector3(modelCenterX, modelCenterY, modelCenterZ))
        
        // Check if camera is already in the scene (e.g., from DAE import)
        if modelScene.rootNode.childNode(withName: "DefaultCamera", recursively: true) == nil {
             modelScene.rootNode.addChildNode(cameraNode)
        } else {
            // Optionally, remove existing cameras or use one from the DAE.
            // For now, we assume our custom camera is preferred.
            modelScene.rootNode.childNode(withName: "DefaultCamera", recursively: true)?.removeFromParentNode()
            modelScene.rootNode.addChildNode(cameraNode)
        }


        // 6. Lighting Setup
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        #if os(macOS)
        ambientLightNode.light!.color = NSColor(white: 0.6, alpha: 1.0)
        #else
        ambientLightNode.light!.color = UIColor(white: 0.6, alpha: 1.0)
        #endif
        modelScene.rootNode.addChildNode(ambientLightNode)

        let directionalLightNode = SCNNode()
        directionalLightNode.light = SCNLight()
        directionalLightNode.light!.type = .directional
        directionalLightNode.light!.castsShadow = true
        #if os(macOS)
        directionalLightNode.light!.color = NSColor(white: 0.8, alpha: 1.0)
        #else
        directionalLightNode.light!.color = UIColor(white: 0.8, alpha: 1.0)
        #endif
        directionalLightNode.position = SCNVector3(x: modelCenterX + modelWidth, y: modelCenterY + modelHeight * 1.5, z: modelCenterZ + modelDepth)
        directionalLightNode.look(at: SCNVector3(modelCenterX, modelCenterY, modelCenterZ))
        modelScene.rootNode.addChildNode(directionalLightNode)
        
        // Optional: Scale the model. Be careful if finalNodeToModify is deep in the hierarchy.
        // It's often better to scale the root node containing the model if the whole model needs scaling.
        // modelScene.rootNode.scale = SCNVector3(0.01, 0.01, 0.01) // Example: if model is huge

        return modelScene
    }

    var body: some View {
        if let validScene = scene {
            SceneView(
                scene: validScene,
                options: [
                    // .allowsCameraControl, // Enable for debugging camera/model placement
                    .autoenablesDefaultLighting, // Can be false if custom lights are extensive
                    .rendersContinuously // May help ensure animations play smoothly
                ]
            )
            .background(Color.clear) // Make SceneView background transparent
        } else {
            // Fallback view if scene loading fails
            Text("Error loading 3D model")
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.2))
        }
    }
}


// 3. Player Column View (Modified)
struct PlayerColumnView: View {
    let player: Player
    // Removed penColor as StickFigureShape is gone

    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 30)
                .strokeBorder(player.color, lineWidth: 5)
                .background(RoundedRectangle(cornerRadius: 30).fill(.white))
                .frame(width: 120, height: 50)
                .overlay {
                    Text(player.name)
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                        .foregroundColor(.black)
                }
            
            // Replace StickFigureShape with BearModelView
            BearModelView(playerColor: player.color)
                .frame(width: 100, height: 150) // Adjust size as needed for the 3D model
                // .background(Color.gray.opacity(0.1)) // Optional: faint background for the 3D view
                .cornerRadius(10) // Optional: rounded corners for the 3D view container

            Text("Ready")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.black)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white)
                        .overlay(Capsule().stroke(.black, lineWidth: 2.5))
                )
        }
    }
}

struct WaitingForPlayerView: View {
    var navigateToGame: () -> Void // Callback for navigation

    var body: some View {
        VStack(spacing: 30) {
            HStack{
                Spacer()
                Text("Waiting for Player")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
                Spacer()
            }
            .background(GameColorScheme().secondaryBackground)
            .frame(maxWidth: .infinity, alignment: .top)
            
            Spacer().frame(height: 30)

            HStack(alignment: .bottom, spacing: 50) {
                ForEach(players) { player in
                    PlayerColumnView(player: player)
                }
            }
            .padding(.bottom, 20)
            
            Button(action: {
                navigateToGame() // Trigger navigation
            }) {
                HStack {
                    Text("Start Adventure")
                        .font( .system(size: 25, weight: .medium, design: .rounded))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundColor(GameColorScheme().primaryText)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(15)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
        }
        .frame(minWidth: 800, idealWidth: 900, maxWidth: .infinity,
               minHeight: 600, idealHeight: 700, maxHeight: .infinity)
        .background(GameColorScheme().primaryBackground)
    }
}

// Update Preview
struct WaitingForPlayerView_Previews: PreviewProvider { // Renamed from #Preview
    static var previews: some View {
        WaitingForPlayerView(navigateToGame: { print("Navigate to Game from preview") })
    }
}
