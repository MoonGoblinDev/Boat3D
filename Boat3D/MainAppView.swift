// Boat3D/App/MainAppView.swift
import SwiftUI

enum ActiveGameScreen {
    case start
    case gameMode
    case playerLoading
    case inGame
}

struct MainAppView: View {
    @State private var currentScreen: ActiveGameScreen = .start

    var body: some View {
        Group {
            switch currentScreen {
            case .start:
                StartScreenView(navigateToGameMode: {
                    currentScreen = .gameMode
                })
            case .gameMode:
                GameModeView(navigateToPlayerLoading: {
                    currentScreen = .playerLoading
                })
            case .playerLoading:
                WaitingForPlayerView(navigateToGame: {
                    currentScreen = .inGame
                })
            case .inGame:
                GameSceneRepresentable()
                    .edgesIgnoringSafeArea(.all) // Game should fill the window
            }
        }
        // Apply a general frame for the window content.
        // The actual window size is set in AppDelegate.
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// This struct will wrap your GameViewController
struct GameSceneRepresentable: NSViewControllerRepresentable {
    typealias NSViewControllerType = GameViewController

    func makeNSViewController(context: Context) -> GameViewController {
        // Instantiate your GameViewController.
        // If it's typically loaded from a storyboard, you'd do that here.
        // For this example, we assume direct instantiation.
        return GameViewController()
    }

    func updateNSViewController(_ nsViewController: GameViewController, context: Context) {
        // This function is called when SwiftUI state that this representable depends on changes.
        // You can use it to pass data or trigger updates in your GameViewController.
        // For now, we don't have specific updates.
    }
}
