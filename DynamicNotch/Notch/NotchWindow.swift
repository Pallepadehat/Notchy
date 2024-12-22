import SwiftUI
import AppKit

final class NotchWindow: NSWindow {
    init() {
        super.init(
            contentRect: .zero,
            styleMask: [.borderless],
            backing: .buffered,
            defer: true
        )
        
        configureWindow()
        setupScreenNotifications()
    }
    
    private func configureWindow() {
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        level = .statusBar
        ignoresMouseEvents = true
        
        // Make it visible on all spaces and stay in place
        collectionBehavior = [.canJoinAllSpaces, .stationary]
        
        // Ensure window stays on top
        isReleasedWhenClosed = false
    }
    
    private func setupScreenNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }
    
    @objc private func screenParametersDidChange() {
        if let screen = NSScreen.main {
            let x = screen.frame.midX - frame.width / 2
            let y = screen.frame.maxY - frame.height
            setFrameOrigin(NSPoint(x: x, y: y))
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
} 