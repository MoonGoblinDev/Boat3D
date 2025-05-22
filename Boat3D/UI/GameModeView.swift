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
        case .map: return "map.fill" // Placeholder icon
        case .advice: return "lightbulb.fill" // Placeholder icon
        case .gems: return "diamond.fill" // Placeholder icon
        }
    }
}

// MARK: - Main View
struct GameModeView: View {
    @State private var selectedGameMode: GameMode?
    @State private var selectedTopTab: TopTab = .map

    let gameModes: [GameMode] = [
        GameMode(name: "Mix", hasNotification: true, previewImageName: "mario_party_preview", description: "An exciting game mode where the topic of the pathway will be random"),
        GameMode(name: "Trivia", previewImageName: "partner_party_preview", description: "An exciting game mode where the topic of the pathway will be a Trivia Question."),
        GameMode(name: "Physcology", previewImageName: "river_survival_preview", description: "An exciting game mode where the topic of the pathway will be a Physcology Question."),
        GameMode(name: "TBA", previewImageName: "sound_stage_preview", description: "Groove to the rhythm in these musical minigames."),
        GameMode(name: "TBA", previewImageName: "minigames_preview", description: "Play all your favorite minigames freely."),
        GameMode(name: "TBA", previewImageName: "online_mariothon_preview", description: "Compete in a series of minigames online."),
        GameMode(name: "TBA", previewImageName: "entrance_preview", description: "Return to the main plaza entrance.")
    ]

    init() {
        // Set initial selection
        _selectedGameMode = State(initialValue: gameModes.first)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top Bar (SL, Tabs, SR)
            //TopBarView(selectedTopTab: $selectedTopTab)

            // Main Content (Sidebar and Map Area)
            HSplitView { // Or HStack if you prefer fixed widths
                LeftSidebarView(gameModes: gameModes, selectedGameMode: $selectedGameMode)
                    .frame(minWidth: 200, idealWidth: 250, maxWidth: 300) // Typical sidebar width
                    .background(Color.gray.opacity(0.1))


                if selectedTopTab == .map {
                    MapContentView(selectedGameMode: $selectedGameMode)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if selectedTopTab == .advice {
                    AdviceContentView() // Placeholder
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if selectedTopTab == .gems {
                    GemsContentView() // Placeholder
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxHeight: .infinity) // Make HSplitView fill vertical space

            // Bottom Bar
            BottomBarView()
        }
        .background(GameColorScheme().primaryBackground) // Or a custom beige
        .edgesIgnoringSafeArea(.top) // If you want the top bar to touch the very top (like traffic lights)
    }
}

// MARK: - Top Bar
struct TopBarView: View {
    @Binding var selectedTopTab: TopTab

    var body: some View {
        HStack {
            Text("< SL")
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal)
                .foregroundColor(.gray)

            Spacer()

            HStack(spacing: 0) {
                ForEach(TopTab.allCases) { tab in
                    Button(action: {
                        selectedTopTab = tab
                    }) {
                        VStack(spacing: 4) {
                            HStack {
                                Image(systemName: tab.iconName)
                                Text(tab.rawValue)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .foregroundColor(selectedTopTab == tab ? .red : .primary)

                            if selectedTopTab == tab {
                                Rectangle()
                                    .fill(Color.red)
                                    .frame(height: 3)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 3)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            Spacer()

            Text("SR >")
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal)
                .foregroundColor(.gray)
        }
        .padding(.top, 5) // Adjusted for macOS window title bar if not ignoring safe area
        .frame(height: 50)
        .background(Color(nsColor: .windowBackgroundColor)) // Or a custom light color
        .overlay(
            Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.3)),
            alignment: .bottom
        )
    }
}

// MARK: - Left Sidebar
struct LeftSidebarView: View {
    let gameModes: [GameMode]
    @Binding var selectedGameMode: GameMode?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
    }
}

struct GameModeButton: View {
    let mode: GameMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                

                if isSelected {
                    Image(systemName: "play.fill") // Or a custom triangle
                        .foregroundColor(.white)
                } else {
                    // Placeholder to maintain alignment
                    Image(systemName: "play.fill")
                        .foregroundColor(.clear)
                }

                Text(mode.name)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(isSelected ? .white : .primary)

                Spacer()
                
//                if mode.hasNotification {
//                    Image(systemName: "exclamationmark.circle.fill")
//                        .foregroundColor(.green)
//                        .font(.title2)
//                } else {
//                    // Keep consistent spacing if no notification
//                    Image(systemName: "exclamationmark.circle.fill")
//                        .foregroundColor(.clear) // Invisible but takes space
//                        .font(.title2)
//                }
                
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            .background(isSelected ? Color.gray.opacity(1) : Color.gray.opacity(0.6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


// MARK: - Map Content View (Right Pane)
struct MapContentView: View {
    @Binding var selectedGameMode: GameMode?

    var body: some View {
        ZStack(alignment: .top) {
            
            VStack{
                if let imageName = selectedGameMode?.previewImageName {
                    ZStack {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 650, height: 300)
                            .background(Color.black.opacity(0.5)) // temp background for placeholder
                            .cornerRadius(8)
                            .shadow(radius: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white, lineWidth: 3)
                              )
                        if imageName == "mario_party_preview_default" { // Example condition for default
                            Text("Preview for \(selectedGameMode?.name ?? "")")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 60) // Adjust positioning
                    .transition(.opacity.combined(with: .scale)) // Nice animation
                }
                
                // Description Text at the bottom
                VStack {
                    if let description = selectedGameMode?.description {
                        HStack {
                            // Star Icon - using SFSymbol, you might need a custom image
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.title3)
                                .opacity(description.contains("Stars win!") ? 1 : 0) // Show only if relevant

                            Text(description.replacingOccurrences(of: "⭐ Stars", with: "Stars")) // Remove custom char if using SFSymbol
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black) // Or a dark gray
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.85))
                                        .shadow(radius: 3)
                                )
                        }
                        .padding()
                        
                        
                    }
                    HStack {
                        Button(action: {
                            // Action for closing party pad
                            print("Close Party Pad pressed")
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
                        .padding()
                    }
                }
            }
            


           
        }
        .onChange(of: selectedGameMode) { _ in
            // Potentially trigger animations or other updates
        }
    }
}

struct BoardPlaceholderView: View {
    let color: Color
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(color)
            .frame(width: 80, height: 50)
            .overlay(
                Image(systemName: "flag.fill") // Placeholder icon on boards
                    .foregroundColor(.white.opacity(0.7))
            )
            .shadow(radius: 3)
    }
}

// MARK: - Placeholder Content for other tabs
struct AdviceContentView: View {
    var body: some View {
        Text("Advice Content Placeholder")
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.orange.opacity(0.2))
    }
}

struct GemsContentView: View {
    var body: some View {
        Text("Gems Content Placeholder")
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.purple.opacity(0.2))
    }
}


// MARK: - Bottom Bar
struct BottomBarView: View {
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                // Action for closing party pad
                print("Close Party Pad pressed")
            }) {
                HStack {
                    //Image(systemName: "xmark.circle.fill") // Or a custom settings/gear icon
                    Text("Let's Play")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundColor(.primary)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(15)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .frame(height: 60)
        .background(GameColorScheme().secondaryBackground)
        .overlay(
            Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.3)),
            alignment: .top
        )
    }
}


// MARK: - Preview
struct GameModeView_Previews: PreviewProvider {
    static var previews: some View {
        GameModeView()
            .frame(width: 1000, height: 700) // Typical window size for preview
    }
}
