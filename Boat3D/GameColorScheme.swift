import SwiftUI

struct GameColorScheme {
    // Backgrounds and UI Elements
    let primaryBackground = Color(hex: 0xFDF6EE) // Light cream background
    let secondaryBackground = Color(hex: 0xd5c1ac) // Dark grey for selected menu item
    let menuItemBackground = Color(hex: 0xF0E6D9) // Lighter cream for unselected menu items
    let menuText = Color(hex: 0x6B6B6B) // Dark grey for menu text
    let selectedMenuText = Color(hex: 0xFFFFFF) // White for selected menu text

    // Map Specific Colors
    let mapGrass = Color(hex: 0x5DCB4A) // Bright green for grass
    let mapPath = Color(hex: 0xFAD89C) // Light sandy color for the path
    let mapBoardOutlineBlue = Color(hex: 0x00A0E9) // Blue outline for map elements
    let mapBoardOutlinePink = Color(hex: 0xEF478F) // Pink outline for map elements
    let mapBoardOutlineRed = Color(hex: 0xE5332A) // Red outline for map elements
    let mapBoardOutlineYellow = Color(hex: 0xFCE02E) // Yellow outline for map elements

    // Accent Colors
    let accentRed = Color(hex: 0xE60012) // Bright red for icons and highlights (like the "!" and tab indicator)
    let accentPink = Color(hex: 0xEE318C) // Pink for the "!" icon background
    let accentYellowStar = Color(hex: 0xFFD700) // Yellow for the star icon

    // Text Colors
    let primaryText = Color(hex: 0x4A4A4A) // Dark grey for general text (like "A board game...")
    let tabTextActive = Color(hex: 0xE60012) // Red for active tab text
    let tabTextInactive = Color(hex: 0x787878) // Grey for inactive tab text

    // Other UI elements
    let bottomBarText = Color(hex: 0x505050) // Dark grey for bottom bar text ("Close Party Pad")
    let controllerButtonIcon = Color(hex: 0x646464) // Grey for controller button icons (SL, SR)
}
