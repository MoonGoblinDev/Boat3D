import SwiftUI

// MARK: - Data Models
struct GameMode: Identifiable, Hashable {
    let id = UUID()
    let name: String
    var hasNotification: Bool = false
    let previewImageName: String // Name of an image asset for the preview
    let description: String
}

enum TopTab: String, CaseIterable, Identifiable {
    case map = "Map"
    case advice = "Advice"
    case gems = "Gems"

    var id: String { self.rawValue }

    var iconName: String {
        switch self {
        case .map: return "map.fill"
        case .advice: return "lightbulb.fill"
        case .gems: return "diamond.fill"
        }
    }
}

// MARK: - Main View
struct GameModeView: View {
    @State private var selectedGameMode: GameMode?
    @State private var selectedTopTab: TopTab = .map

    var navigateToPlayerLoading: () -> Void // Callback for navigation

    let gameModes: [GameMode] = [
        GameMode(name: "Mix", hasNotification: true, previewImageName: "mario_party_preview", description: "An exciting game mode where the topic of the pathway will be random"),
        GameMode(name: "Trivia", previewImageName: "partner_party_preview", description: "An exciting game mode where the topic of the pathway will be a Trivia Question."),
        GameMode(name: "Physcology", previewImageName: "river_survival_preview", description: "An exciting game mode where the topic of the pathway will be a Physcology Question."),
        GameMode(name: "TBA", previewImageName: "sound_stage_preview", description: "Groove to the rhythm in these musical minigames."),
        GameMode(name: "TBA", previewImageName: "minigames_preview", description: "Play all your favorite minigames freely."),
        GameMode(name: "TBA", previewImageName: "online_mariothon_preview", description: "Compete in a series of minigames online."),
        GameMode(name: "TBA", previewImageName: "entrance_preview", description: "Return to the main plaza entrance.")
    ]

    init(navigateToPlayerLoading: @escaping () -> Void) {
        self.navigateToPlayerLoading = navigateToPlayerLoading
        // Set initial selection
        _selectedGameMode = State(initialValue: gameModes.first)
    }

    var body: some View {
        VStack(spacing: 0) {
            // TopBarView was here, removed as per request (unused)
            // If you had tabs or other top bar elements, they would be here.
            // For simplicity based on current structure, we can add a simple tab selector.
            Picker("Select Tab", selection: $selectedTopTab) {
                ForEach(TopTab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()


            // Main Content (Sidebar and Content Area)
            HSplitView {
                LeftSidebarView(gameModes: gameModes, selectedGameMode: $selectedGameMode)
                    .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
                    .background(GameColorScheme().menuItemBackground) // Using color scheme

                // Content based on selected tab
                Group {
                    switch selectedTopTab {
                    case .map:
                        MapContentView(selectedGameMode: $selectedGameMode, navigateToPlayerLoading: navigateToPlayerLoading)
                    case .advice:
                        AdviceContentView()
                    case .gems:
                        GemsContentView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxHeight: .infinity) // Make HSplitView fill vertical space

            // Bottom Bar
            BottomBarView()
        }
        .background(GameColorScheme().primaryBackground)
        .edgesIgnoringSafeArea(.top) // If you want the top bar to touch the very top
    }
}

// MARK: - Left Sidebar
struct LeftSidebarView: View {
    let gameModes: [GameMode]
    @Binding var selectedGameMode: GameMode?
    private let colorScheme = GameColorScheme()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Game Modes")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 10)
                .foregroundColor(colorScheme.primaryText)

            ForEach(gameModes) { mode in
                GameModeButton(
                    mode: mode,
                    isSelected: selectedGameMode?.id == mode.id,
                    action: { selectedGameMode = mode }
                )
            }
            Spacer()
        }
        .padding()
        .background(colorScheme.primaryBackground) // Sidebar background
    }
}

struct GameModeButton: View {
    let mode: GameMode
    let isSelected: Bool
    let action: () -> Void
    private let colorScheme = GameColorScheme()

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isSelected {
                    Image(systemName: "play.fill") // Triangle indicator
                        .foregroundColor(colorScheme.selectedMenuText)
                        .transition(.opacity) // Add a little animation
                } else {
                    // Placeholder to maintain alignment when not selected
                    Image(systemName: "play.fill")
                        .foregroundColor(.clear)
                }

                Text(mode.name)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(isSelected ? colorScheme.selectedMenuText : colorScheme.menuText)

                Spacer()
                
                if mode.hasNotification && !isSelected { // Show notification only if not selected
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(colorScheme.accentPink) // Using color scheme
                        .font(.title3)
                } else if mode.hasNotification && isSelected {
                     Image(systemName: "exclamationmark.circle.fill") // Keep consistent spacing
                        .foregroundColor(colorScheme.accentRed) // Different color for selected
                        .font(.title3)
                }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            .background(isSelected ? colorScheme.secondaryBackground : colorScheme.menuItemBackground)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


// MARK: - Map Content View (Right Pane)
struct MapContentView: View {
    @Binding var selectedGameMode: GameMode?
    var navigateToPlayerLoading: () -> Void // Callback for navigation
    private let colorScheme = GameColorScheme()

    var body: some View {
        VStack { // Main container for map content
            Spacer() // Push content towards center or allow flexible spacing

            if let gameMode = selectedGameMode {
                VStack(spacing: 30) { // Group image and description
                    // Preview Image
                    ZStack {
                        Image(gameMode.previewImageName) // Ensure these images exist
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 600, maxHeight: 350) // Adjusted size
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(colorScheme.mapBoardOutlineBlue, lineWidth: 4) // Using color scheme
                            )
                        
                        // Example: Display mode name on image if needed
                        // Text(gameMode.name)
                        //     .font(.title)
                        //     .fontWeight(.bold)
                        //     .foregroundColor(.white)
                        //     .padding(8)
                        //     .background(Color.black.opacity(0.5))
                        //     .cornerRadius(8)
                    }
                    .padding(.horizontal) // Add some horizontal padding for the image container
                    .transition(.opacity.combined(with: .scale(scale: 0.9))) // Animation for image change

                    // Description Text
                    HStack {
                        // Star Icon (Optional, based on description content)
                        if gameMode.description.contains("Star") || gameMode.description.contains("star") { // Generic check
                            Image(systemName: "star.fill")
                                .foregroundColor(colorScheme.accentYellowStar) // Using color scheme
                                .font(.title3)
                        }

                        Text(gameMode.description)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(colorScheme.primaryText)
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(colorScheme.menuItemBackground.opacity(0.85)) // Using color scheme
                                    .shadow(color: .gray.opacity(0.4), radius: 3, x: 0, y: 2)
                            )
                    }
                    .padding(.horizontal) // Padding for the description box
                    
                }
                .animation(.easeInOut, value: gameMode.id) // Animate changes when gameMode changes
                
            } else {
                Text("Select a game mode from the left.")
                    .font(.headline)
                    .foregroundColor(colorScheme.primaryText)
            }

            Spacer() // Push content towards center

            // "Start Adventure" Button
            Button(action: {
                navigateToPlayerLoading() // Trigger navigation
            }) {
                Text("Start Adventure")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .foregroundColor(colorScheme.selectedMenuText) // White text
                    .background(colorScheme.accentRed) // Red button
                    .cornerRadius(12)
                    .shadow(color: colorScheme.accentRed.opacity(0.5), radius: 5, x: 0, y: 3)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.bottom, 30) // Padding at the bottom for the button
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorScheme.primaryBackground) // Background for the content area
        .onChange(of: selectedGameMode) { _ in
            // Potential additional actions on mode change
        }
    }
}

// MARK: - Placeholder Content for other tabs
struct AdviceContentView: View {
    private let colorScheme = GameColorScheme()
    var body: some View {
        VStack {
            Text("Advice Content")
                .font(.largeTitle)
                .foregroundColor(colorScheme.primaryText)
            Text("Tips and tricks for the game will appear here.")
                .font(.title3)
                .foregroundColor(colorScheme.menuText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorScheme.primaryBackground.opacity(0.8)) // Slightly different background
    }
}

struct GemsContentView: View {
    private let colorScheme = GameColorScheme()
    var body: some View {
        VStack {
            Text("Gems Collection")
                .font(.largeTitle)
                .foregroundColor(colorScheme.primaryText)
            Text("View your collected gems and achievements.")
                .font(.title3)
                .foregroundColor(colorScheme.menuText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorScheme.primaryBackground.opacity(0.8))
    }
}


// MARK: - Bottom Bar
struct BottomBarView: View {
    private let colorScheme = GameColorScheme()
    var body: some View {
        HStack {
            Spacer() // Pushes button to the right or center if you add more items
            Button(action: {
                // Action for this button - e.g., go back, or open settings
                // For now, it's a placeholder or could be removed if MapContentView's button is sufficient
                print("Bottom Bar Button (e.g., 'Options' or 'Back') pressed")
            }) {
                HStack {
                    Image(systemName: "gearshape.fill") // Example icon
                    Text("Options") // Example text
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .foregroundColor(colorScheme.bottomBarText)
                .background(colorScheme.menuItemBackground)
                .cornerRadius(10)
                .shadow(radius: 2)
            }
            .buttonStyle(PlainButtonStyle())
            Spacer() // Centers the button if only one item
        }
        .padding()
        .frame(height: 70) // Increased height for better touch/click area
        .background(colorScheme.secondaryBackground) // Darker background for contrast
        .overlay(
            Rectangle().frame(height: 1).foregroundColor(colorScheme.menuText.opacity(0.3)),
            alignment: .top
        )
    }
}


// MARK: - Preview
struct GameModeView_Previews: PreviewProvider {
    static var previews: some View {
        GameModeView(navigateToPlayerLoading: { print("Navigate to Player Loading from preview") })
            .frame(width: 1000, height: 700)
    }
}
