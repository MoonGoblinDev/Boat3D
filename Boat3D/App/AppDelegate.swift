//
//  AppDelegate.swift
//  Boat3D
//
//  Created by Bregas Satria Wicaksono on 19/05/25.
//

import Cocoa

// MARK: - Extension for macOS app delegate

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the window

    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
