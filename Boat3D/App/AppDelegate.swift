//
//  AppDelegate.swift
//  Boat3D
//
//  Created by Bregas Satria Wicaksono on 19/05/25.
//

import Cocoa
import SwiftUI // <-- Import SwiftUI

// MARK: - Extension for macOS app delegate

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = MainAppView() // <-- Use our new root view

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 700), // Initial size
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("MainAppWindow") // For window position saving
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        window.title = "Boat3D Adventure" // Optional: Set a window title
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
